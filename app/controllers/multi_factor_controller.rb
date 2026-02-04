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
  # Supports both email OTP and TOTP verification, as well as backup codes.
  # The user's MFA method is detected automatically.
  #
  # @api POST /auth/verify_multi_factor
  # @param temp_token [String] temporary token from initial sign-in
  # @param otp_code [String] 6-digit code from email/app or 8-char backup code
  # @return [JSON] user data and auth tokens in headers
  # @status 200 OTP verified, auth tokens issued
  # @status 401 Invalid or expired OTP/temp_token
  # @status 403 Account locked due to failed attempts
  # @status 422 Missing required parameters
  def verify
    if params[:temp_token].blank? || params[:otp_code].blank?
      return render json: {errors: ["temp_token and otp_code are required"]}, status: 422
    end

    user_id = Rails.cache.read("otp_temp_token:#{params[:temp_token]}")
    return render json: {errors: ["Invalid or expired temp token"]}, status: :unauthorized unless user_id

    @resource = User.find_by(id: user_id)
    return render json: {errors: ["User not found"]}, status: :unauthorized unless @resource

    # Check if account is locked due to failed MFA attempts
    if @resource.mfa_locked?
      return render json: {
        errors: ["Account temporarily locked due to too many failed attempts. Try again in 30 minutes."]
      }, status: :forbidden
    end

    # Verify code based on user's MFA method
    code_valid = case @resource.mfa_method
    when :totp
      verify_totp_code
    when :email_otp
      verify_email_otp_code
    else
      false
    end

    unless code_valid
      @resource.increment_mfa_failed_attempts!
      return render json: {errors: ["Invalid multi-factor code"]}, status: :unauthorized
    end

    # Code verified! Generate auth tokens and reset failed attempts
    complete_authentication
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

  private

  ##
  # Verifies TOTP code or backup code.
  def verify_totp_code
    # Check if it's a backup code (8 characters, alphanumeric)
    if params[:otp_code].length == 8 && params[:otp_code].match?(/^[a-z0-9]+$/i)
      return BackupCode.use_code(@resource, params[:otp_code])
    end

    # Otherwise treat as TOTP code
    @resource.validate_totp_code(params[:otp_code])
  end

  ##
  # Verifies email OTP code.
  def verify_email_otp_code
    return false if @resource.multi_factor_email_code_expired?
    @resource.validate_multi_factor_email_code(params[:otp_code])
  end

  ##
  # Completes authentication by issuing tokens.
  def complete_authentication
    # Clear temp token and OTP data
    Rails.cache.delete("otp_temp_token:#{params[:temp_token]}")

    if @resource.mfa_method == :email_otp
      @resource.update_columns(multi_factor_email_code: nil, multi_factor_email_code_sent_at: nil)
    end

    # Reset failed attempts
    @resource.reset_mfa_failed_attempts!

    # Generate auth tokens
    @client_id = SecureRandom.urlsafe_base64(nil, false)
    @token = SecureRandom.urlsafe_base64(nil, false)
    @expiry = (Time.current + DeviseTokenAuth.token_lifespan).to_i

    @resource.tokens ||= {}
    @resource.tokens[@client_id] = {
      token: BCrypt::Password.create(@token),
      expiry: @expiry
    }

    @resource.save!

    # Set response headers
    response.headers["access-token"] = @token
    response.headers["client"] = @client_id
    response.headers["uid"] = @resource.uid
    response.headers["expiry"] = @expiry.to_s
    response.headers["token-type"] = "Bearer"

    render json: {data: @resource.token_validation_response}
  end
end
