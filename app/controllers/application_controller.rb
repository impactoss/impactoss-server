# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit::Authorization
  rescue_from StandardError, with: :handle_error_in_json_format
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authenticate_user!, unless: :skip_authentication?
  after_action :verify_authorized, except: [:index], unless: :devise_or_devise_token_auth_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_or_devise_token_auth_controller?

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_paper_trail_whodunnit

  # Allow pundit to authorize a non-logged in user
  def pundit_user
    current_user || User.new
  end

  protected

  def devise_or_devise_token_auth_controller?
    devise_controller? || self.class.name.start_with?("DeviseTokenAuth::")
  end

  def serialize(target, serializer:)
    serializer.new(target).serializable_hash.to_json
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    return if performed?
    render json: {error: e.message}, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |invalid|
    return if performed?
    render json: {error: invalid.record.errors},
      status: :unprocessable_entity
  end

  rescue_from ActionController::ParameterMissing do |e|
    return if performed?
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private

  def handle_error_in_json_format(exception)
    return if performed?
    status = case exception
    when ActiveRecord::RecordNotFound then :not_found
    when ActionController::ParameterMissing then :bad_request
    when Pundit::NotAuthorizedError then :forbidden
    else :internal_server_error
    end

    error_message = exception.message
    error_message = "Resource not found" if exception.is_a?(ActiveRecord::RecordNotFound)

    if Rails.env.test? || Rails.env.development?
      error_details = {
        error: error_message,
        exception_class: exception.class.name,
        backtrace: exception.backtrace.first(5)
      }
      Rails.logger.error "API Error: #{error_details.inspect}"
      render json: error_details, status: status
    else
      render json: {error: error_message}, status: status
    end
  end

  def user_not_authorized
    return if performed?
    render json: {error: "not authorized"}, status: 403
  end

  def skip_authentication?
    devise_or_devise_token_auth_controller? || action_name == "index"
  end

  # Re-authentication gate for sensitive actions. The client always sends
  # current_password on these requests, so this only rejects direct API calls
  # (e.g. a hijacked session attempting a sensitive change).
  def require_current_password!
    password = params[:current_password]
    return true if password.present? && current_user&.valid_password?(password)

    render json: {
      status: "error",
      errors: {current_password: ["is incorrect or missing"]}
    }, status: :unauthorized
    false
  end
end
