class RolesController < ApplicationController
  before_action :set_and_authorize_role, only: [:show, :update, :destroy]

  # GET /roles
  def index
    @roles = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @roles

    render json: serialize(@roles)
  end

  # GET /roles/1
  def show
    render json: serialize(@role)
  end

  # POST /roles
  def create
    @role = Role.new
    @role.assign_attributes(permitted_attributes(@role))
    authorize @role

    if @role.save
      render json: serialize(@role), status: :created, location: @role
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /roles/1
  def update
    render json: serialize(@role) if @role.update_attributes!(permitted_attributes(@role))
  end

  # DELETE /roles/1
  def destroy
    @role.destroy
  end

  private

  def base_object
    Role
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_role
    @role = policy_scope(base_object).find(params[:id])
    authorize @role
  end

  def serialize(target, serializer: RoleSerializer)
    super
  end
end
