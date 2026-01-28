# frozen_string_literal: true

##
# Custom sessions controller with password security checks.
#
# NOTE: This will be merged with branch feature/two-factor-authentication later.
# Security checks here will run BEFORE the 2FA flow.
class SessionsController < DeviseTokenAuth::SessionsController
  # these skips likely technically redundant - TODO: review after merge
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false

  def create
    # SECURITY CHECKS - Run before password validation
    user = User.find_by(email: resource_params[:email])

    # Check 1: Locked accounts cannot sign in
    if user&.access_locked?
      return render json: {
        error: I18n.t("devise.failure.locked")
      }, status: :unauthorized
    end

    # Check 2: Expired passwords must be reset
    if user&.password_expired?
      return render json: {
        error: I18n.t("devise.failure.password_expired"),
        reason: "password_expired"
      }, status: :unauthorized
    end

    # Proceed with normal authentication
    super
  end

  protected

  # Enhanced error rendering with last-attempt warning
  def render_create_error_bad_credentials
    attempted_user = resource_class.find_by(email: resource_params[:email])

    if attempted_user
      max_attempts = Devise.maximum_attempts || 5

      # Warn on last attempt before lockout
      if attempted_user.failed_attempts == (max_attempts - 1)
        Rails.logger.debug "[SessionsController] Last attempt before lock"
        return render json: {
          error: I18n.t("devise.failure.last_attempt"),
          reason: "last_attempt"
        }, status: :unauthorized
      end
    end

    # Default bad credentials error
    super
  end

  private

  def resource_params
    params.permit(:email, :password)
  end
end
