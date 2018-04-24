class UserCategoriesController < ApplicationController
  before_action :set_and_authorize_user_category, only: [:show, :update, :destroy]

  # GET /user_categories
  def index
    @user_categories = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @user_categories

    render json: serialize(@user_categories)
  end

  # GET /user_categories/1
  def show
    render json: serialize(@user_category)
  end

  # POST /user_categories
  def create
    @user_category = UserCategory.new
    @user_category.assign_attributes(permitted_attributes(@user_category))
    authorize @user_category

    if @user_category.save
      render json: serialize(@user_category), status: :created, location: @user_category
    else
      render json: @user_category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_categories/1
  def update
    if @user_category.update_attributes!(permitted_attributes(@user_category))
      render json: serialize(@user_category)
    end
  end

  # DELETE /user_categories/1
  def destroy
    @user_category.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_user_category
    @user_category = policy_scope(base_object).find(params[:id])
    authorize @user_category
  end

  def base_object
    UserCategory
  end

  def serialize(target, serializer: UserCategorySerializer)
    super
  end
end
