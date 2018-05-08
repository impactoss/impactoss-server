class RecommendationMeasuresController < ApplicationController
  before_action :set_and_authorize_recommendation_measure, only: [:show, :update, :destroy]

  # GET /recommendation_measures
  def index
    @recommendation_measures = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @recommendation_measures

    render json: serialize(@recommendation_measures)
  end

  # GET /recommendation_measures/1
  def show
    render json: serialize(@recommendation_measure)
  end

  # POST /recommendation_measures
  def create
    @recommendation_measure = RecommendationMeasure.new
    @recommendation_measure.assign_attributes(permitted_attributes(@recommendation_measure))
    authorize @recommendation_measure

    if @recommendation_measure.save
      render json: serialize(@recommendation_measure), status: :created, location: @recommendation_measure
    else
      render json: @recommendation_measure.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recommendation_measures/1
  def update
    if @recommendation_measure.update_attributes!(permitted_attributes(@recommendation_measure))
      render json: serialize(@recommendation_measure)
    end
  end

  # DELETE /recommendation_measures/1
  def destroy
    @recommendation_measure.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_recommendation_measure
    @recommendation_measure = policy_scope(base_object).find(params[:id])
    authorize @recommendation_measure
  end

  def base_object
    RecommendationMeasure
  end

  def serialize(target, serializer: RecommendationMeasureSerializer)
    super
  end
end
