class MeasureCategoriesController < ApplicationController
  before_action :set_and_authorize_measure_category, only: [:destroy]

  # GET /measure_categories
  def index
    @measure_categories = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @measure_categories

    render json: serialize(@measure_categories)
  end

  # POST /measure_categories
  def create
    @measure_category = MeasureCategory.new
    @measure_category.assign_attributes(permitted_attributes(@measure_category))
    authorize @measure_category

    if @measure_category.save_with_cleanup
      render json: serialize(@measure_category), status: :created, location: @measure_category
    else
      render json: @measure_category.errors, status: :unprocessable_entity
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
  rescue ActiveRecord::RecordNotFound
    if action_name == "destroy"
      record = base_object.find_by(id: params[:id])

      if record.present?
        # Record exists but is out of scope — test authorization anyway
        authorize record
      end

      # If we got here, it's okay to respond as deleted
      head :no_content
    else
      raise
    end
  end

  def base_object
    MeasureCategory
  end

  def serialize(target, serializer: MeasureCategorySerializer)
    super
  end
end
