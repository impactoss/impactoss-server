class RecommendationCategoriesController < ApplicationController
  before_action :set_and_authorize_recommendation_category, only: [:show, :destroy]
  skip_before_action :authenticate_user!, only: [:update]

  # GET /recommendation_categories
  def index
    @recommendation_categories = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @recommendation_categories

    render json: serialize(@recommendation_categories)
  end

  # GET /recommendation_categories/1
  def show
    render json: serialize(@recommendation_category)
  end

  # POST /recommendation_categories
  def create
    @recommendation_category = RecommendationCategory.new
    @recommendation_category.assign_attributes(permitted_attributes(@recommendation_category))
    authorize @recommendation_category

    if @recommendation_category.save_with_cleanup
      render json: serialize(@recommendation_category), status: :created, location: @recommendation_category
    else
      render json: @recommendation_category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /recommendation_categories/1
  def destroy
    @recommendation_category.destroy
  end

  def update
    head :not_implemented
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_recommendation_category
    @recommendation_category = policy_scope(base_object).find(params[:id])
    authorize @recommendation_category
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
    RecommendationCategory
  end

  def serialize(target, serializer: RecommendationCategorySerializer)
    super
  end
end
