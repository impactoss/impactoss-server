class UsersController < ApplicationController
  before_action :authenticate_user!

  before_action :set_and_authorize_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @users

    render json: serialize(@users)
  end

  # GET /users/1
  def show
    render json: serialize(@user)
  end

  # POST /users
  def create
    @user = User.new
    @user.assign_attributes(permitted_attributes(@user))
    authorize @user

    if @user.save
      render json: serialize(@user), status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    render json: serialize(@user) if @user.update_attributes!(permitted_attributes(@user))
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private

  def base_object
    User
  end

  def serialize(target, serializer: UserSerializer)
    super
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_user
    @user = policy_scope(base_object).find(params[:id])
    authorize @user
  end
end
