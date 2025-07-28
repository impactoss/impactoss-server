class UserCategoriesController < ApplicationController
  before_action :set_and_authorize_user_category, only: [:show, :destroy]
  skip_before_action :authenticate_user!, only: [:update]

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

    if @user_category.save_with_cleanup
      render json: serialize(@user_category), status: :created, location: @user_category
    else
      render json: @user_category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /user_categories/1
  def destroy
    @user_category.destroy
  end

  def update
    head :not_implemented
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_user_category
    @user_category = policy_scope(base_object).find(params[:id])
    authorize @user_category
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
    UserCategory
  end

  def serialize(target, serializer: UserCategorySerializer)
    super
  end
end
