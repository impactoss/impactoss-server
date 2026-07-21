# frozen_string_literal: true

##
# Custom registrations controller for devise-token-auth.
#
# Extends DeviseTokenAuth::RegistrationsController to skip
# ApplicationController callbacks and add MFA support for new registrations.
class RegistrationsController < DeviseTokenAuth::RegistrationsController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false
  skip_after_action :update_auth_header

  ##
  # Handles user registration with optional multi-factor authentication.
  #
  # When MFA is enabled globally, new users must verify their email with an OTP
  # before being fully signed in. This prevents automatic sign-in on registration.
  #
  # @api POST /auth
  # @param email [String] user's email address
  # @param password [String] user's password
  # @param password_confirmation [String] password confirmation
  # @param name [String] user's name
  # @return [JSON] either temp_token (MFA) or auth tokens (no MFA)
  # @status 202 MFA required, OTP sent
  # @status 200 Registered and signed in successfully (no MFA)
  # @status 422 Validation errors
  def create
    super do |resource|
      if resource.persisted? && Rails.application.config.enable_mfa
        # User created successfully - send OTP instead of auto-signing in
        resource.generate_and_send_multi_factor_email!
        temp_token = SecureRandom.urlsafe_base64(32)
        Rails.cache.write("otp_temp_token:#{temp_token}", resource.id, expires_in: 5.minutes)

        return render json: {
          otp_required: true,
          temp_token:,
          message: "Registration successful! Multi-factor code sent to your email"
        }, status: :accepted
      end
    end
  end

  def destroy
    render json: {error: "Account deletion is not available"}, status: :forbidden
  end

  ##
  # On a password change, invalidate the user's other sessions by keeping only
  # the token from the current request and dropping the rest.
  #
  # The slice runs before super because devise_token_auth prunes the tokens hash
  # during the password-change save (inside update_with_password), so reshaping
  # tokens here means that save persists just the current session. The current
  # token's value is unchanged, so the browser stays authenticated without
  # refreshed auth headers (which this controller skips via skip_after_action).
  #
  # Guarded on a password being present so that non-password account updates do
  # not drop the user's other sessions. Only password changes reach this endpoint
  # in normal app use (profile fields go through UsersController), so the guard is
  # defensive - it keeps the invalidation tied strictly to password changes should
  # another update ever be routed here.
  def update
    if @resource && @token && account_update_params[:password].present?
      @resource.tokens = @resource.tokens.slice(@token.client)
    end
    super
  end
end
