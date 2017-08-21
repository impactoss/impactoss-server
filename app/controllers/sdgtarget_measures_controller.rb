class SdgtargetMeasuresController < ApplicationController
  before_action :set_and_authorize_sdgtarget_measure, only: [:show, :update, :destroy]

  # GET /sdgtarget_categories
  def index
    @sdgtarget_categories = policy_scope(SdgtargetMeasure).order(created_at: :desc).page(params[:page])
    authorize @sdgtarget_categories

    render json: @sdgtarget_categories
  end

  # GET /sdgtarget_categories/1
  def show
    render json: @sdgtarget_measure
  end

  # POST /sdgtarget_categories
  def create
    @sdgtarget_measure = SdgtargetMeasure.new
    @sdgtarget_measure.assign_attributes(permitted_attributes(@sdgtarget_measure))
    authorize @sdgtarget_measure

    if @sdgtarget_measure.save
      render json: @sdgtarget_measure, status: :created, location: @sdgtarget_measure
    else
      render json: @sdgtarget_measure.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sdgtarget_categories/1
  def update
    render json: @sdgtarget_measure if @sdgtarget_measure.update_attributes!(permitted_attributes(@sdgtarget_measure))
  end

  # DELETE /sdgtarget_categories/1
  def destroy
    @sdgtarget_measure.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_sdgtarget_measure
    @sdgtarget_measure = policy_scope(SdgtargetMeasure).find(params[:id])
    authorize @sdgtarget_measure
  end
end
