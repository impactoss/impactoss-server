class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_and_authorize_user, only: [:update]
  before_action :require_current_password!, only: [:update], if: :email_change_requested?

  # GET /users
  def index
    @users = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @users

    render json: serialize(@users)
  end

  # PATCH/PUT /users/1
  def update
    render json: serialize(@user) if @user.update!(permitted_attributes(@user))
  end

  private

  def base_object
    User
  end

  def serialize(target, serializer: UserSerializer)
    return super if base_object === target && policy(target).show_email?

    JSON.parse(super).tap do |json|
      if Array === json["data"]
        json["data"].each do |data|
          data["attributes"].delete("email") unless policy(base_object.new(id: data["id"])).show_email?
        end
      else
        json["data"]["attributes"].delete("email")
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_user
    @user = policy_scope(base_object).find(params[:id])
    authorize @user
  end

  def email_change_requested?
    new_email = permitted_attributes(@user)[:email]
    new_email.present? && new_email != @user.email
  end
end
