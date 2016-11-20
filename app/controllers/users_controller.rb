class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update]
  after_action :verify_authorized, except: :index

  def index
    authorize :user
    @users = policy_scope(User)
  end

  def edit
    authorize @user
    @roles = Role.all
  end

  def update
    authorize @user
    @user.update(user_params)
    @user.save!
    redirect_to users_path
  rescue
    render :edit, @user
  end

  private

  def user_params
    u = params.require(:user).permit(:name, :email, role_ids: [])
    u[:role_ids] = [] if u[:role_ids].blank?
    u
  end

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end
end
