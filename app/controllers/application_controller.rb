# frozen_string_literal: true
class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery with: :exception

  layout :layout_by_resource

  after_action :verify_authorized, except: [:index, :sign_in], unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  protected

  def layout_by_resource
    devise_controller? ? 'authentication' : 'application'
  end

  private

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform this action.'
    redirect_to(root_path)
  end
end
