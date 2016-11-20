# frozen_string_literal: true
class DashboardsController < ApplicationController
  after_action :verify_authorized
  def show
    authorize :dashboard
  end
end
