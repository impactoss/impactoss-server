class FrameworksController < ApplicationController
  # before_action :authenticate_user!

  # GET /frameworks
  def index
    if(params[:framework_id])
      @frameworks = policy_scope(base_object)
        .find(params[:framework_id])
        .frameworks
    else
      @frameworks = policy_scope(base_object)
    end

    render json: serialize(@frameworks.order(created_at: :desc).page(params[:page]))
  end

  # GET /frameworks/[id]
  def show
    @framework = policy_scope(base_object).find(params[:id])
    authorize @framework

    render json: serialize(@framework)
  end

  private

  def base_object
    Framework
  end

  def serialize(target, serializer: FrameworkSerializer)
    super
  end
end
