class FrameworkFrameworksController < ApplicationController
  # GET /framework_frameworks/:id
  def show
    @framework_framework = policy_scope(base_object).find(params[:id])
    authorize @framework_framework
    render json: serialize(@framework_framework)
  end

  def index
    @framework_frameworks = policy_scope(base_object).all
    authorize @framework_frameworks
    render json: serialize(@framework_frameworks)
  end

  private

  def base_object
    FrameworkFramework
  end

  def serialize(target, serializer: FrameworkFrameworkSerializer)
    super
  end

end