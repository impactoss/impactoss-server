# frozen_string_literal: true
class MeasuresController < ApplicationController
  before_action :set_and_authorize_measure, only: [:show, :update, :destroy]

  # GET /measures
  def index
    @measures = policy_scope(base_object).order(created_at: :desc).page(params[:page])
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
    if params[:measure][:updated_at] && DateTime.parse(params[:measure][:updated_at]).to_i != @measure.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    render json: @measure if @measure.update_attributes!(permitted_attributes(@measure))
  end

  # DELETE /measures/1
  def destroy
    @measure.destroy
  end

  private

  def base_object
    return Category.find(params[:category_id]).measures if params[:category_id]
    return Recommendation.find(params[:recommendation_id]).measures if params[:recommendation_id]
    return Indicator.find(params[:indicator_id]).measures if params[:indicator_id]

    Measure
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_measure
    @measure = policy_scope(base_object).find(params[:id])
    authorize @measure
  end
end
