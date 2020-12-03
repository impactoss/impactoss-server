class RecommendationRecommendationsController < ApplicationController
  # GET /recommendation_recommendations/:id
  def show
    @recommendation_recommendation = policy_scope(base_object).find(params[:id])
    authorize @recommendation_recommendation
    render json: serialize(@recommendation_recommendation)
  end

  def index
    @recommendation_recommendations = policy_scope(base_object).all
    authorize @recommendation_recommendations
    render json: serialize(@recommendation_recommendations)
  end

  private

  def base_object
    RecommendationRecommendation
  end

  def serialize(target, serializer: RecommendationRecommendationSerializer)
    super
  end

end