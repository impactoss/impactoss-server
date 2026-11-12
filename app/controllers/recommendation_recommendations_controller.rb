class RecommendationRecommendationsController < ApplicationController
  before_action :set_and_authorize_recommendation_recommendation, only: [:destroy]

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
      render json: serialize(@recommendation_recommendation), status: :created, location: @recommendation_recommendation
    else
      render_connection_create_errors(@recommendation_recommendation)
    end
  end

  def destroy
    @recommendation_recommendation.destroy
  end

  private

  def set_and_authorize_recommendation_recommendation
    @recommendation_recommendation = policy_scope(base_object).find(params[:id])
    authorize @recommendation_recommendation
  rescue ActiveRecord::RecordNotFound
    if action_name == "destroy"
      record = base_object.find_by(id: params[:id])

      if record.present?
        # Record exists but is out of scope — test authorization anyway
        authorize record
      end

      # If we got here, it's okay to respond as deleted
      head :no_content
    else
      raise
    end
  end

  def base_object
    RecommendationRecommendation
  end

  def serialize(target, serializer: RecommendationRecommendationSerializer)
    super
  end
end
