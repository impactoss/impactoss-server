class DueDatesController < ApplicationController
  before_action :set_and_authorize_due_date, only: [:show, :update, :destroy]

  # GET /due_dates
  def index
    @due_dates = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @due_dates

    render json: serialize(@due_dates)
  end

  # GET /due_dates/1
  def show
    render json: serialize(@due_date)
  end

  # POST /due_dates
  def create
    @due_date = DueDate.new
    @due_date.assign_attributes(permitted_attributes(@due_date))
    authorize @due_date

    if @due_date.save
      render json: serialize(@due_date), status: :created, location: @due_date
    else
      render json: @due_date.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /due_dates/1
  def update
    if @due_date.update_attributes!(permitted_attributes(@due_date))
      set_and_authorize_due_date
      render json: serialize(@due_date)
    end
  end

  # DELETE /due_dates/1
  def destroy
    @due_date.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_due_date
    @due_date = policy_scope(base_object).find(params[:id])
    authorize @due_date
  end

  def base_object
    DueDate
  end

  def serialize(target, serializer: DueDateSerializer)
    super
  end
end
