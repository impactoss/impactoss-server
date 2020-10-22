# frozen_string_literal: true
class RecommendationsController < ApplicationController
  before_action :set_and_authorize_recommendation, only: [:show, :update, :destroy]

  # GET /recommendations
  def index
    if(params[:recommendation_id])
      @recommendations = policy_scope(base_object)
        .find(params[:recommendation_id])
        .recommendations
    else
      @recommendations = policy_scope(base_object)
    end

    authorize @recommendations

    render json: serialize(@recommendations.order(created_at: :desc).page(params[:page]))
  end

  # GET /recommendations/1
  def show
    render json: serialize(@recommendation)
  end

  # POST /recommendations
  def create
    # POST /recommendations/[id]/recommendations
    if(params[:recommendation_id].presence && params[:other_recommendation_id].presence)
      return associate_recommendation
    end

    # POST /indicators/[id]/recommendations
    if(params[:indicator_id].presence && params[:recommendation_id].presence)
      return associate_indicator
    end

    @recommendation = Recommendation.new
    @recommendation.assign_attributes(permitted_attributes(@recommendation))
    authorize @recommendation

    if @recommendation.save
      render json: serialize(@recommendation), status: :created, location: @recommendation
    else
      render json: @recommendation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recommendations/1
  def update
    if params[:recommendation][:updated_at] && DateTime.parse(params[:recommendation][:updated_at]).to_i != @recommendation.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    if @recommendation.update_attributes!(permitted_attributes(@recommendation))
      set_and_authorize_recommendation
      render json: serialize(@recommendation)
    end
  end

  # DELETE /recommendations/1
  def destroy
    if(params[:recommendation_id].presence && params[:other_recommendation_id].presence)
      @recommendation = Recommendation.find(params[:recommendation_id])
      other_recommendation = Recommendation.find(params[:other_recommendation_id])

      return @recommendation.recommendations.delete(other_recommendation)
    end

    if(params[:id].presence && params[:indicator_id].presence)
      indicator = Indicator.find(params[:indicator_id])
      recommendation = Recommendation.find(params[:id])

      return indicator.direct_recommendations.delete(recommendation)
    end

    @recommendation.destroy
  end

  private

  def base_object
    if params[:category_id]
      Category.find(params[:category_id]).recommendations
    elsif params[:measure_id]
      Measure.find(params[:measure_id]).recommendations
    elsif params[:indicator_id]
      Indicator.find(params[:indicator_id]).direct_recommendations
    else
      Recommendation
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_recommendation
    @recommendation = policy_scope(base_object).find(params[:id])
    authorize @recommendation
  end

  def serialize(target, serializer: RecommendationSerializer)
    super
  end

  def associate_recommendation
    @recommendation = Recommendation.find(params[:recommendation_id])
    other_recommendation = Recommendation.find(params[:other_recommendation_id])
    authorize @recommendation
    authorize other_recommendation

    if !@recommendation.recommendations.exists?(params[:other_recommendation_id])
      @recommendation.recommendations << other_recommendation
    end

    render json: {
      recommendation_id: params[:recommendation_id].to_s,
      other_recommendation_id: params[:other_recommendation_id].to_s
    }, status: :created
  end

  def associate_indicator
    indicator = Indicator.find(params[:indicator_id])
    recommendation = Recommendation.find(params[:recommendation_id])
    authorize indicator
    authorize recommendation

    if !indicator.direct_recommendations.exists?(params[:recommendation_id])
      indicator.direct_recommendations << recommendation
    end

    render json: {
      indicator_id: params[:indicator_id].to_s,
      recommendation_id: params[:recommendation_id].to_s
    }, status: :created
  end
end
