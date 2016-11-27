class IndicatorsController < ApplicationController
  def new
    @indicator = Indicator.new
    authorize @indicator
  end

  def create
    @indicator = Indicator.new
    @indicator.assign_attributes(permitted_attributes(@indicator))

    authorize @indicator

    if @indicator.save
      redirect_to indicator_path(@indicator), notice: 'Indicator created'
    else
      render :new
    end
  end

  def index
    @indicators = policy_scope(Indicator).order(created_at: :desc).page(params[:page])
    authorize @indicators
  end

  def edit
    @indicator = Indicator.find(params[:id])
    authorize @indicator
  end

  def update
    @indicator = Indicator.find(params[:id])
    authorize @indicator

    if @indicator.update_attributes(permitted_attributes(@indicator))
      redirect_to indicator_path, notice: 'Indicator updated'
    else
      render :edit
    end
  end

  def show
    @indicator = Indicator.find(params[:id])
    authorize @indicator
  end

  def destroy
    @indicator = Indicator.find(params[:id])
    authorize @indicator

    if @indicator.destroy
      redirect_to indicators_path, notice: 'Indicator deleted'
    else
      redirect_to indicators_path, notice: 'Unable to delete Indicator'
    end
  end
end
