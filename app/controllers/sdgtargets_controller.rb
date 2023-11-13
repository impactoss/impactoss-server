# frozen_string_literal: true

class SdgtargetsController < ApplicationController
  before_action :set_and_authorize_sdgtarget, only: [:show, :update, :destroy]

  # GET /sdgtargets
  def index
    @sdgtargets = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @sdgtargets

    render json: serialize(@sdgtargets)
  end

  # GET /sdgtargets/1
  def show
    render json: serialize(@sdgtarget)
  end

  # POST /sdgtargets
  def create
    @sdgtarget = Sdgtarget.new
    @sdgtarget.assign_attributes(permitted_attributes(@sdgtarget))
    authorize @sdgtarget

    if @sdgtarget.save
      render json: serialize(@sdgtarget), status: :created, location: @sdgtarget
    else
      render json: @sdgtarget.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sdgtargets/1
  def update
    if params[:sdgtarget][:updated_at] && DateTime.parse(params[:sdgtarget][:updated_at]).to_i != @sdgtarget.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    if @sdgtarget.update!(permitted_attributes(@sdgtarget))
      set_and_authorize_sdgtarget
      render json: serialize(@sdgtarget)
    end
  end

  # DELETE /sdgtargets/1
  def destroy
    @sdgtarget.destroy
  end

  private

  def base_object
    if params[:category_id]
      Category.find(params[:category_id]).measures
    elsif params[:recommendation_id]
      Recommendation.find(params[:recommendation_id]).measures
    elsif params[:indicator_id]
      Indicator.find(params[:indicator_id]).measures
    else
      Sdgtarget
    end
  end

  def serialize(target, serializer: SdgtargetSerializer)
    super
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_sdgtarget
    @sdgtarget = policy_scope(base_object).find(params[:id])
    authorize @sdgtarget
  end
end
