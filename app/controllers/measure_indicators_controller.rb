class MeasureIndicatorsController < ApplicationController
  before_action :set_and_authorize_measure_indicator, only: [:show, :update, :destroy]

  # GET /measure_categories
  def index
    @measure_categories = policy_scope(MeasureIndicator).order(created_at: :desc).page(params[:page])
    authorize @measure_categories

    render json: @measure_categories
  end

  # GET /measure_categories/1
  def show
    render json: @measure_indicator
  end

  # POST /measure_categories
  def create
    @measure_indicator = MeasureIndicator.new
    @measure_indicator.assign_attributes(permitted_attributes(@measure_indicator))
    authorize @measure_indicator

    if @measure_indicator.save
      render json: @measure_indicator, status: :created, location: @measure_indicator
    else
      render json: @measure_indicator.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /measure_categories/1
  def update
    render json: @measure_indicator if @measure_indicator.update_attributes!(permitted_attributes(@measure_indicator))
  end

  # DELETE /measure_categories/1
  def destroy
    @measure_indicator.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_measure_indicator
    @measure_indicator = policy_scope(MeasureIndicator).find(params[:id])
    authorize @measure_indicator
  end
end
