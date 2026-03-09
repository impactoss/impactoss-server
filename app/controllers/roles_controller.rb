class RolesController < ApplicationController
  # GET /roles
  def index
    @roles = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @roles

    render json: serialize(@roles)
  end

  private

  def base_object
    Role
  end

  def serialize(target, serializer: RoleSerializer)
    super
  end
end
