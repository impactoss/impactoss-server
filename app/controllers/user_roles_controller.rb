class UserRolesController < ApplicationController
  before_action :set_and_authorize_user_role, only: [:show, :update, :destroy]

  # GET /user_roles
  def index
    @user_roles = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @user_roles

    render json: serialize(@user_roles)
  end

  # GET /@user_roles/1
  def show
    render json: serialize(@user_role)
  end

  # POST /user_roles
  def create
    @user_role = UserRole.new
    @user_role.assign_attributes(permitted_attributes(@user_role))
    authorize @user_role

    if @user_role.save
      render json: serialize(@user_role), status: :created, location: @user_role
    else
      render json: @user_role.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_roles/1
  def update
    if @user_role.update_attributes!(permitted_attributes(@user_role))
      render json: serialize(@user_role)
    end
  end

  # DELETE /user_roles/1
  def destroy
    @user_role.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_user_role
    @user_role = policy_scope(base_object).find(params[:id])
    authorize @user_role
  end

  def base_object
    UserRole
  end

  def serialize(target, serializer: UserRoleSerializer)
    super
  end
end
