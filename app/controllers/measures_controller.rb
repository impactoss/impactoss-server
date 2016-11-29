# frozen_string_literal: true
class MeasuresController < ApplicationController
  def new
    @measure = Measure.new
    authorize @measure
  end

  def create
    @measure = Measure.new
    @measure.assign_attributes(permitted_attributes(@measure))
    authorize @measure

    if @measure.save
      redirect_to measure_path(@measure), notice: 'Action created'
    else
      render :new
    end
  end

  def index
    @measures = policy_scope(Measure).order(created_at: :desc).page(params[:page])
    authorize @measures
  end

  def edit
    @measure = Measure.find(params[:id])
    authorize @measure
  end

  def update
    @measure = Measure.find(params[:id])
    authorize @measure

    if @measure.update_attributes(permitted_attributes(@measure))
      redirect_to measure_path, notice: 'Action updated'
    else
      render :edit
    end
  end

  def show
    @measure = Measure.find(params[:id])
    authorize @measure
  end

  def destroy
    @measure = Measure.find(params[:id])
    authorize @measure

    if @measure.destroy
      redirect_to measures_path, notice: 'Action deleted'
    else
      redirect_to measures_path, notice: 'Unable to delete Action'
    end
  end
end
