class RecommendationIndicatorsController < ApplicationController
  before_action :set_and_authorize_recommendation_indicator, only: [:show, :destroy]

  def index
    @recommendation_indicators = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @recommendation_indicators

    render json: serialize(@recommendation_indicators)
  end

  def show
    render json: serialize(@recommendation_indicator)
  end

  def create
    @recommendation_indicator = RecommendationIndicator.new
    @recommendation_indicator.assign_attributes(permitted_attributes(@recommendation_indicator))
    authorize @recommendation_indicator

    if @recommendation_indicator.save
      render json: serialize(@recommendation_indicator), status: :created, location: @recommendation_indicator
    else
      render json: @recommendation_indicator.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @recommendation_indicator.destroy
  end

  private

  def set_and_authorize_recommendation_indicator
    @recommendation_indicator = policy_scope(base_object).find(params[:id])
    authorize @recommendation_indicator
  end

  def base_object
    RecommendationIndicator
  end

  def serialize(target, serializer: RecommendationIndicatorSerializer)
    super
  end
end
