class IndicatorsController < ApplicationController
  def new
    @indicator = Indicator.new
    authorize @indicator
  end

  def index
    @indicators = policy_scope(Indicator.all)
  end

  def edit
    @indicator = Indicator.find(params[:id])
    authorize @indicator
  end

  def update
    @indicator = Indicator.find(params[:id])
    authorize @indicator

    if @indicator.update_attributes(permitted_attributes(@indicator))
      redirect_to recommendation_path, notice: "Indicator updated"
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
      redirect_to recommendations_path, notice: "Indicator deleted"
    else
      redirect_to recommendations_path, notice: "Unable to delete Indicator"
    end
  end
end
