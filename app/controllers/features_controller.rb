class FeaturesController < ApplicationController
  def index
    render json: {features: Features::FEATURES}
  end
end
