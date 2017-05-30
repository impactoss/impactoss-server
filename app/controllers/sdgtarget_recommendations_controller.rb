class SdgtargetRecommendationsController < ApplicationController
  before_action :set_and_authorize_sdgtarget_recommendation, only: [:show, :update, :destroy]

  # GET /sdgtarget_categories
  def index
    @sdgtarget_categories = policy_scope(SdgtargetRecommendation).order(created_at: :desc).page(params[:page])
    authorize @sdgtarget_categories

    render json: @sdgtarget_categories
  end

  # GET /sdgtarget_categories/1
  def show
    render json: @sdgtarget_recommendation
  end

  # POST /sdgtarget_categories
  def create
    @sdgtarget_recommendation = SdgtargetRecommendation.new
    @sdgtarget_recommendation.assign_attributes(permitted_attributes(@sdgtarget_recommendation))
    authorize @sdgtarget_recommendation

    if @sdgtarget_recommendation.save
      render json: @sdgtarget_recommendation, status: :created, location: @sdgtarget_recommendation
    else
      render json: @sdgtarget_recommendation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sdgtarget_categories/1
  def update
    render json: @sdgtarget_recommendation if @sdgtarget_recommendation.update_attributes!(permitted_attributes(@sdgtarget_recommendation))
  end

  # DELETE /sdgtarget_categories/1
  def destroy
    @sdgtarget_recommendation.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_sdgtarget_recommendation
    @sdgtarget_recommendation = policy_scope(SdgtargetRecommendation).find(params[:id])
    authorize @sdgtarget_recommendation
  end
end
