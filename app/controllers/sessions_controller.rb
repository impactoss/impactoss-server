# frozen_string_literal: true

##
# Custom sessions controller that adds multi-factor authentication support.
#
# Extends DeviseTokenAuth::SessionsController to intercept the sign-in flow
# and require OTP verification when MFA is enabled for a user.
class SessionsController < DeviseTokenAuth::SessionsController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false
  ##
  # Handles user sign-in with optional multi-factor authentication.
  #
  # When a user with MFA enabled attempts to sign in, this endpoint:
  # 1. Validates email/password credentials
  # 2. Generates and sends an OTP via email
  # 3. Returns a temp_token for OTP verification
  #
  # For users without MFA, it proceeds with normal token authentication.
  #
  # @api POST /auth/sign_in
  # @param email [String] user's email address
  # @param password [String] user's password
  # @return [JSON] either temp_token (MFA) or auth tokens (no MFA)
  # @status 202 MFA required, OTP sent
  # @status 200 Signed in successfully (no MFA)
  # @status 401 Invalid credentials
  #
  # @example Request (MFA enabled)
  #   POST /auth/sign_in
  #   {
  #     "email": "user@example.com",
  #     "password": "password123"
  #   }
  #
  # @example Response (MFA required)
  #   HTTP 202 Accepted
  #   {
  #     "otp_required": true,
  #     "temp_token": "abc123...",
  #     "message": "Multi-factor code sent to your email"
  #   }
  #
  # @example Response (no MFA)
  #   HTTP 200 OK
  #   Headers:
  #     access-token: "xyz789..."
  #     client: "client_id"
  #     uid: "user@example.com"
  #   Body:
  #     { "data": { "id": 1, "email": "user@example.com", ... } }
  def create
    # Authenticate user by email/password first
    field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

    @resource = nil
    if field
      q_value = get_case_insensitive_field_from_resource_params(field)
      @resource = find_resource(field, q_value)
    end

    if @resource && valid_params?(field, q_value) && @resource.valid_password?(resource_params[:password])
      # Password is valid - check if MFA is enabled
      if @resource.multi_factor_email_code_enabled?
        @resource.generate_and_send_multi_factor_email!
        temp_token = SecureRandom.urlsafe_base64(32)
        Rails.cache.write("otp_temp_token:#{temp_token}", @resource.id, expires_in: 5.minutes)

        render json: {otp_required: true, temp_token: temp_token, message: "Multi-factor code sent to your email"}, status: :accepted
      else
        super
      end
    else
      # Invalid credentials
      render_create_error_bad_credentials
    end
  end

  private

  def valid_params?(key, val)
    resource_params[:password] && key && val
  end

  def get_case_insensitive_field_from_resource_params(field)
    # honor Devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(field)
      resource_params[field].downcase
    else
      resource_params[field]
    end
  end

  def find_resource(field, value)
    @resource = resource_class.dta_find_by(field => value)
  end
end
