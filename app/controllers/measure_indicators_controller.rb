class MeasureIndicatorsController < ApplicationController
  before_action :set_and_authorize_measure_indicator, only: [:show, :destroy]
  skip_before_action :authenticate_user!, only: [:update]

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

  # DELETE /measure_indicators/1
  def destroy
    @measure_indicator.destroy
  end

  def update
    head :not_implemented
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_measure_indicator
    @measure_indicator = policy_scope(base_object).find(params[:id])
    authorize @measure_indicator
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
    MeasureIndicator
  end

  def serialize(target, serializer: MeasureIndicatorSerializer)
    super
  end
end
