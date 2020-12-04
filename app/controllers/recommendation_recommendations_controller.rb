class RecommendationRecommendationsController < ApplicationController
  before_action :set_and_authorize_recommendation_recommendation, only: [:show, :destroy]

  def show
    render json: serialize(@recommendation_recommendation)
  end

  def index
    @recommendation_recommendations = policy_scope(base_object).all
    authorize @recommendation_recommendations
    render json: serialize(@recommendation_recommendations)
  end

  def create
    @recommendation_recommendation = RecommendationRecommendation.new
    @recommendation_recommendation.assign_attributes(permitted_attributes(@recommendation_recommendation))
    authorize @recommendation_recommendation

    if @recommendation_recommendation.save
      render json: @recommendation_recommendation, status: :created, location: @recommendation_recommendation
    else
      render json: @recommendation_recommendation.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @recommendation_recommendation.destroy
  end

  private

  def set_and_authorize_recommendation_recommendation
    @recommendation_recommendation = policy_scope(base_object).find(params[:id])
    authorize @recommendation_recommendation
  end

  def base_object
    RecommendationRecommendation
  end

  def serialize(target, serializer: RecommendationRecommendationSerializer)
    super
  end

end