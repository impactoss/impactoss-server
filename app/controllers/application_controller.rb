# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit::Authorization
  rescue_from StandardError, with: :handle_error_in_json_format
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  layout :layout_by_resource

  before_action :authenticate_user!, only: [:create, :update, :destroy], unless: :devise_controller?
  after_action :verify_authorized, except: [:index], unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_paper_trail_whodunnit

  # Allow pundit to authorize a non-logged in user
  def pundit_user
    current_user || User.new
  end

  protected

  def serialize(target, serializer:)
    serializer.new(target).serializable_hash.to_json
  end

  def layout_by_resource
    devise_controller? ? "authentication" : "application"
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: {error: e.message}, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |invalid|
    render json: {error: invalid.record.errors},
      status: :unprocessable_entity
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private def handle_error_in_json_format(exception)
    # Only handle JSON format requests or API endpoints
    if request.format.json? || request.path.match?(/\/(framework_|api)/)
      status = case exception
      when ActiveRecord::RecordNotFound then :not_found
      when ActionController::ParameterMissing then :bad_request
      when Pundit::NotAuthorizedError then :forbidden
      else :internal_server_error
      end

      error_message = exception.message
      error_message = "Resource not found" if exception.is_a?(ActiveRecord::RecordNotFound)

      # Add detailed error info in test environment
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
    else
      # Re-raise the exception for non-API requests
      raise exception
    end
  end

  private def user_not_authorized
    if request.format == "application/json"
      return render json: {error: "not authorized"}, status: 403
    end

    flash[:error] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end
end
