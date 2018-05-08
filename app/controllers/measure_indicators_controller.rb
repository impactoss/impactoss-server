class MeasureIndicatorsController < ApplicationController
  before_action :set_and_authorize_measure_indicator, only: [:show, :update, :destroy]

  # GET /measure_indicators
  def index
    @measure_indicators = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @measure_indicators

    render json: serialize(@measure_indicators)
  end

  # GET /measure_indicators/1
  def show
    render json: serialize(@measure_indicator)
  end

  # POST /measure_indicators
  def create
    @measure_indicator = MeasureIndicator.new
    @measure_indicator.assign_attributes(permitted_attributes(@measure_indicator))
    authorize @measure_indicator

    if @measure_indicator.save
      render json: serialize(@measure_indicator), status: :created, location: @measure_indicator
    else
      render json: @measure_indicator.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /measure_indicators/1
  def update
    if @measure_indicator.update_attributes!(permitted_attributes(@measure_indicator))
      set_and_authorize_measure_indicator
      render json: serialize(@measure_indicator)
    end
  end

  # DELETE /measure_indicators/1
  def destroy
    @measure_indicator.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_measure_indicator
    @measure_indicator = policy_scope(base_object).find(params[:id])
    authorize @measure_indicator
  end

  def base_object
    MeasureIndicator
  end

  def serialize(target, serializer: MeasureIndicatorSerializer)
    super
  end
end
