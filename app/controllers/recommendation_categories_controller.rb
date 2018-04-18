class RecommendationCategoriesController < ApplicationController
  before_action :set_and_authorize_recommendation_category, only: [:show, :update, :destroy]

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

    if @recommendation_category.save
      render json: serialize(@recommendation_category), status: :created, location: @recommendation_category
    else
      render json: @recommendation_category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recommendation_categories/1
  def update
    if @recommendation_category.update_attributes!(permitted_attributes(@recommendation_category))
      render json: serialize(@recommendation_category)
    end
  end

  # DELETE /recommendation_categories/1
  def destroy
    @recommendation_category.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_recommendation_category
    @recommendation_category = policy_scope(base_object).find(params[:id])
    authorize @recommendation_category
  end

  def base_object
    RecommendationCategory
  end

  def serialize(target, serializer: RecommendationCategorySerializer)
    super
  end
end
