# frozen_string_literal: true
class RecommendationsController < ApplicationController
  before_action :set_and_authorize_recommendation, only: [:show, :update, :destroy]

  # GET /recommendations
  def index
    @recommendations = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @recommendations

    render json: @recommendations
  end

  # GET /recommendations/1
  def show
    render json: @recommendation
  end

  # POST /recommendations
  def create
    @recommendation = Recommendation.new
    @recommendation.assign_attributes(permitted_attributes(@recommendation))
    authorize @recommendation

    if @recommendation.save
      render json: @recommendation, status: :created, location: @recommendation
    else
      render json: @recommendation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recommendations/1
  def update
    if params[:recommendation][:updated_at] && DateTime.parse(params[:recommendation][:updated_at]).to_i != @recommendation.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    render json: @recommendation if @recommendation.update_attributes!(permitted_attributes(@recommendation))
  end

  # DELETE /recommendations/1
  def destroy
    @recommendation.destroy
  end

  private

  def base_object
    return Category.find(params[:category_id]).recommendations if params[:category_id]
    return Measure.find(params[:measure_id]).recommendations if params[:measure_id]

    Recommendation
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_recommendation
    @recommendation = policy_scope(base_object).find(params[:id])
    authorize @recommendation
  end
end
