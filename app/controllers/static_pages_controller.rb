class StaticPagesController < ApplicationController
  after_action :verify_authorized, except: :home

  def home
    # Static Page
  end

  def index
    head :not_implemented
  end

  def create
    head :not_implemented
  end

  def update
    head :not_implemented
  end

  def destroy
    head :not_implemented
  end
end
