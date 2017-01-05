# frozen_string_literal: true
class MeasuresController < ApplicationController
  before_action :set_and_authorize_measure, only: [:show, :update, :destroy]

  # GET /measures
  def index
    @measures = policy_scope(Measure).order(created_at: :desc).page(params[:page])
    authorize @measures

    render json: @measures
  end

  # GET /measures/1
  def show
    render json: @measure
  end

  # POST /measures
  def create
    @measure = Measure.new
    @measure.assign_attributes(permitted_attributes(@measure))
    authorize @measure

    if @measure.save
      render json: @measure, status: :created, location: @measure
    else
      render json: @measure.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /measures/1
  def update
    render json: @measure if @measure.update_attributes!(permitted_attributes(@measure))
  end

  # DELETE /measures/1
  def destroy
    @measure.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_measure
    @measure = policy_scope(Measure).find(params[:id])
    authorize @measure
  end
end
