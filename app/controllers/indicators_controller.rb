class IndicatorsController < ApplicationController
  before_action :set_indicator, only: [:show, :edit, :update, :destroy]

  def new
    @indicator = Indicator.new
    authorize @indicator
  end

  def create
    @indicator = Indicator.new
    @indicator.assign_attributes(permitted_attributes(@indicator))

    authorize @indicator

    @indicator.save!
    redirect_to indicator_path(@indicator), notice: 'Indicator created'
  rescue
    render :new
  end

  def index
    @indicators = policy_scope(Indicator).order(created_at: :desc).page(params[:page])
    authorize @indicators
  end

  def edit
  end

  def update
    @indicator.update_attributes!(permitted_attributes(@indicator))
    redirect_to indicator_path, notice: 'Indicator updated'
  rescue
    render :edit
  end

  def show
  end

  def destroy
    @indicator.destroy!
    redirect_to indicators_path, notice: 'Indicator deleted'
  rescue
    redirect_to indicators_path, notice: 'Unable to delete Indicator'
  end

  private

  def set_indicator
    @indicator = Indicator.find(params[:id])
    authorize @indicator
  end
end
