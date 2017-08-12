class IndicatorsController < ApplicationController
  before_action :set_and_authorize_indicator, only: [:show, :update, :destroy]

  # GET /indicators
  def index
    @indicators = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @indicators

    render json: @indicators
  end

  # GET /indicators/1
  def show
    render json: @indicator
  end

  # POST /indicators
  def create
    @indicator = Indicator.new
    @indicator.assign_attributes(permitted_attributes(@indicator))
    authorize @indicator

    if @indicator.save
      render json: @indicator, status: :created, location: @indicator
    else
      render json: @indicator.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /indicators/1
  def update
    if params[:indicator][:updated_at] && DateTime.parse(params[:indicator][:updated_at]).to_i != @indicator.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    render json: @indicator if @indicator.update_attributes!(permitted_attributes(@indicator))
  end

  # DELETE /indicators/1
  def destroy
    @indicator.destroy
  end

  private

  def base_object
    return Measure.find(params[:measure_id]).indicators if params[:measure_id]

    Indicator
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_indicator
    @indicator = policy_scope(base_object).find(params[:id])
    authorize @indicator
  end
end
