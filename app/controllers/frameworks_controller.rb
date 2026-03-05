class FrameworksController < ApplicationController
  # GET /frameworks
  def index
    @frameworks = policy_scope(base_object).page(params[:page])

    if params[:framework_id]
      @frameworks = policy_scope(base_object)
        .find(params[:framework_id])
        .frameworks
    end

    render json: serialize(@frameworks)
  end

  private

  def base_object
    Framework
  end

  def serialize(target, serializer: FrameworkSerializer)
    super
  end
end
