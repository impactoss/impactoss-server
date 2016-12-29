class StaticPagesController < ApplicationController
  after_action :verify_authorized, except: :home

  def home
    # Static Page
  end
end
