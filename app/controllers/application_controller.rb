# frozen_string_literal: true
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, unless: :devise_controller?
  layout :layout_by_resource

  protected

  def layout_by_resource
    devise_controller? ? "authentication" : "application"
  end
end
