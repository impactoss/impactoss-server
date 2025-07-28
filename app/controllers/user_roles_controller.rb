class UserRolesController < ApplicationController
  before_action :set_and_authorize_user_role, only: [:show, :destroy]
  skip_before_action :authenticate_user!, only: [:update]

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

  # DELETE /user_roles/1
  def destroy
    @user_role.destroy
  end

  def update
    head :not_implemented
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_user_role
    @user_role = policy_scope(base_object).find(params[:id])
    authorize @user_role
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
    UserRole
  end

  def serialize(target, serializer: UserRoleSerializer)
    super
  end
end
