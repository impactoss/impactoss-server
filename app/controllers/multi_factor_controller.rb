# frozen_string_literal: true

##
# Handles multi-factor authentication OTP verification.
#
# This controller manages the second step of the MFA login flow,
# verifying OTP codes and issuing authentication tokens.
class MultiFactorController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken

  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false
  skip_after_action :update_auth_header

  ##
  # Verifies a multi-factor authentication code and issues auth tokens.
  #
  # After a user successfully authenticates with email/password,
  # they receive a temp_token and an OTP via email. This endpoint
  # validates the OTP and exchanges the temp_token for real auth tokens.
  #
  # @api POST /auth/verify_multi_factor
  # @param temp_token [String] temporary token from initial sign-in
  # @param otp_code [String] 6-digit code from email
  # @return [JSON] user data and auth tokens in headers
  # @status 200 OTP verified, auth tokens issued
  # @status 401 Invalid or expired OTP/temp_token
  # @status 422 Missing required parameters
  #
  # @example Request
  #   POST /auth/verify_multi_factor
  #   {
  #     "temp_token": "abc123...",
  #     "otp_code": "123456"
  #   }
  #
  # @example Response Headers
  #   access-token: "xyz789..."
  #   client: "client_id"
  #   uid: "user@example.com"
  #
  # @example Response Body
  #   {
  #     "data": {
  #       "id": 1,
  #       "email": "user@example.com",
  #       ...
  #     }
  #   }
  def verify
    if params[:temp_token].blank? || params[:otp_code].blank?
      return render json: {errors: ["temp_token and otp_code are required"]}, status: 422
    end

    user_id = Rails.cache.read("otp_temp_token:#{params[:temp_token]}")
    return render json: {errors: ["Invalid or expired temp token"]}, status: :unauthorized unless user_id

    @resource = User.find_by(id: user_id)

    return render json: {errors: ["User not found"]}, status: :unauthorized unless @resource

    if @resource.multi_factor_email_code_expired?
      return render json: {errors: ["Multi-factor code has expired"]}, status: :unauthorized
    end

    unless @resource.validate_multi_factor_email_code(params[:otp_code])
      return render json: {errors: ["Invalid multi-factor code"]}, status: :unauthorized
    end

    # OTP verified! Generate auth tokens
    Rails.cache.delete("otp_temp_token:#{params[:temp_token]}")
    @resource.update_columns(multi_factor_email_code: nil, multi_factor_email_code_sent_at: nil)

    @client_id = SecureRandom.urlsafe_base64(nil, false)
    @token = SecureRandom.urlsafe_base64(nil, false)
    @expiry = (Time.current + DeviseTokenAuth.token_lifespan).to_i

    @resource.tokens ||= {}
    @resource.tokens[@client_id] = {
      token: BCrypt::Password.create(@token),
      expiry: @expiry
    }

    @resource.save!

    response.headers["access-token"] = @token
    response.headers["client"] = @client_id
    response.headers["uid"] = @resource.uid
    response.headers["expiry"] = @expiry.to_s
    response.headers["token-type"] = "Bearer"

    render json: {data: @resource.token_validation_response}
  end

  ##
  # Resends a new OTP code to the user's email.
  #
  # If the user didn't receive the original OTP or it expired,
  # this endpoint generates and sends a new code while keeping
  # the same temp_token active.
  #
  # @api POST /auth/resend_multi_factor
  # @param temp_token [String] temporary token from initial sign-in
  # @return [JSON] success message
  # @status 200 New OTP sent successfully
  # @status 401 Invalid or expired temp_token
  # @status 422 Missing temp_token parameter
  #
  # @example Request
  #   POST /auth/resend_multi_factor
  #   {
  #     "temp_token": "abc123..."
  #   }
  #
  # @example Response
  #   {
  #     "message": "Multi-factor code re-sent to your email"
  #   }
  def resend
    return render json: {errors: ["temp_token is required"]}, status: 422 unless params[:temp_token]

    user_id = Rails.cache.read("otp_temp_token:#{params[:temp_token]}")
    return render json: {errors: ["Invalid or expired temp token"]}, status: :unauthorized unless user_id

    @resource = User.find_by(id: user_id)
    return render json: {errors: ["User not found"]}, status: :unauthorized unless @resource

    # Regenerate and send new OTP
    @resource.generate_and_send_multi_factor_email!

    render json: {message: "Multi-factor code re-sent to your email"}, status: :ok
  end
end
