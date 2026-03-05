class DueDatesController < ApplicationController
  # GET /due_dates
  def index
    @due_dates = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @due_dates

    render json: serialize(@due_dates)
  end

  private

  def base_object
    DueDate
  end

  def serialize(target, serializer: DueDateSerializer)
    super
  end
end
