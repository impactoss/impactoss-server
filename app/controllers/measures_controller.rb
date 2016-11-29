# frozen_string_literal: true
class MeasuresController < ApplicationController
  before_action :set_measure, only: [:show, :edit, :update, :destroy]

  def new
    @measure = Measure.new
    authorize @measure
  end

  def create
    @measure = Measure.new
    authorize @measure
    @measure.assign_attributes!(permitted_attributes(@measure))
    @measure.save!
    redirect_to measure_path(@measure), notice: t('notice.measure.create.success')
  rescue
    render :new
  end

  def index
    @measures = policy_scope(Measure).order(created_at: :desc).page(params[:page])
    authorize @measures
  end

  def edit
  end

  def update
    @measure.update_attributes(permitted_attributes(@measure))
    redirect_to measure_path, notice: t('notice.measure.update.success')
  rescue
    render :edit
  end

  def show
  end

  def destroy
    @measure.destroy!
    redirect_to measures_path, notice: t('notice.measure.delete.success')
  rescue
    redirect_to measures_path, notice: t('notice.measure.delete.fail')
  end

  private

  def set_measure
    @measure = Measure.find(params[:id])
    authorize @measure
  end
end
