class CategoriesController < ApplicationController
  before_action :set_and_authorize_category, only: [:show, :update, :destroy]

  # GET /categories
  def index
    @categories = policy_scope(Category).order(created_at: :desc).page(params[:page])
    authorize @categories

    render json: @categories
  end

  # GET /categories/1
  def show
    render json: @category
  end

  # POST /categories
  def create
    @category = Category.new
    @category.assign_attributes(permitted_attributes(@category))
    authorize @category

    if @category.save
      render json: @category, status: :created, location: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    render json: @category if @category.update_attributes!(permitted_attributes(@category))
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_category
    @category = policy_scope(Category).find(params[:id])
    authorize @category
  end
end
