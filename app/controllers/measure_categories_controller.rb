class MeasureCategoriesController < ApplicationController
  before_action :set_and_authorize_measure_category, only: [:show, :update, :destroy]

  # GET /measure_categories
  def index
    @measure_categories = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @measure_categories

    render json: serialize(@measure_categories)
  end

  # GET /measure_categories/1
  def show
    render json: serialize(@measure_category)
  end

  # POST /measure_categories
  def create
    @measure_category = MeasureCategory.new
    @measure_category.assign_attributes(permitted_attributes(@measure_category))
    authorize @measure_category

    if @measure_category.save
      render json: serialize(@measure_category), status: :created, location: @measure_category
    else
      render json: @measure_category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /measure_categories/1
  def update
    if @measure_category.update_attributes!(permitted_attributes(@measure_category))
      set_and_authorize_measure_category
      render json: serialize(@measure_category)
    end
  end

  # DELETE /measure_categories/1
  def destroy
    @measure_category.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_measure_category
    @measure_category = policy_scope(base_object).find(params[:id])
    authorize @measure_category
  end

  def base_object
    MeasureCategory
  end

  def serialize(target, serializer: MeasureCategorySerializer)
    super
  end
end
