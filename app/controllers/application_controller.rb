# frozen_string_literal: true
class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery with: :exception

  before_action :authenticate_user!, unless: :devise_controller?
  layout :layout_by_resource

  protected

  def layout_by_resource
    devise_controller? ? "authentication" : "application"
  end

  private

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    redirect_to(request_referrer || root_path)
  end
end
