class FrameworkFrameworksController < ApplicationController
  def index
    @framework_frameworks = policy_scope(base_object).all
    authorize @framework_frameworks
    render json: serialize(@framework_frameworks)
  end

  def base_object
    FrameworkFramework
  end

  def serialize(target, serializer: FrameworkFrameworkSerializer)
    super
  end
end
