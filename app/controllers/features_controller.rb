class FeaturesController < ApplicationController
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def index
    render json: {features: Features::FEATURES}
  end
end
