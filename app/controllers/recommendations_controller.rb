# frozen_string_literal: true

class RecommendationsController < ApplicationController
  before_action :set_and_authorize_recommendation, only: [:update, :destroy]

  # GET /recommendations
  def index
    @recommendations = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @recommendations

    render json: serialize(@recommendations)
  end

  # POST /recommendations
  def create
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
    if @recommendation.update!(permitted_attributes(@recommendation))
      set_and_authorize_recommendation
      render json: serialize(@recommendation)
    end
  end

  # DELETE /recommendations/1
  def destroy
    @recommendation.destroy
  end

  private

  def base_object
    records = Recommendation

    records = records.where(is_archive: false) if params[:include_archive] == "false"
    records = records.where(id: records.select(&:is_current).map(&:id)) if params[:current_only] == "true"
    records
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_recommendation
    @recommendation = policy_scope(base_object).find(params[:id])
    authorize @recommendation
  end

  def serialize(target, serializer: RecommendationSerializer)
    super
  end
end
