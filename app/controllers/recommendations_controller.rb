# frozen_string_literal: true
class RecommendationsController < ApplicationController
  def new
    @recommendation = Recommendation.new
    authorize @recommendation
  end

  def index
    @recommendations = policy_scope(Recommendation.order(:title).page params[:page])
  end

  def edit
    @recommendation = Recommendation.find(params[:id])
    authorize @recommendation
  end

  def update
    @recommendation = Recommendation.find(params[:id])
    authorize @recommendation

    if @recommendation.update_attributes(permitted_attributes(@recommendation))
      redirect_to recommendation_path, notice: "Recommendation updated"
    else
      render :edit
    end
  end

  def show
    @recommendation = Recommendation.find(params[:id])
    authorize @recommendation
  end

  def destroy
    @recommendation = Recommendation.find(params[:id])
    authorize @recommendation

    if @recommendation.destroy
      redirect_to recommendations_path, notice: "Recommendation deleted"
    else
      redirect_to recommendations_path, notice: "Unable to delete Recommendation"
    end
  end
end
