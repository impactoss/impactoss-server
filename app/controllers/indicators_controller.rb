class IndicatorsController < ApplicationController
  before_action :set_and_authorize_indicator, only: [:update, :destroy]

  # GET /indicators
  def index
    @indicators = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @indicators

    render json: serialize(@indicators)
  end

  # POST /indicators
  def create
    @indicator = Indicator.new
    @indicator.assign_attributes(permitted_attributes(@indicator))
    authorize @indicator

    if @indicator.save
      render json: serialize(@indicator),
        status: :created, location: @indicator
    else
      render json: @indicator.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /indicators/1
  def update
    if params[:indicator][:updated_at] && DateTime.parse(params[:indicator][:updated_at]).to_i != @indicator.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    if @indicator.update!(permitted_attributes(@indicator))
      set_and_authorize_indicator
      render json: serialize(@indicator)
    end
  end

  # DELETE /indicators/1
  def destroy
    @indicator.destroy
  end

  private

  def base_object
    records = Indicator

    records = records.where(is_archive: false) if params[:include_archive] == "false"
    # Resolved as a set once per request rather than per record; see
    # CurrentCycle. Must stay a relation so ordering, paging and policy_scope
    # still compose.
    records = records.where.not(id: Current.cycle.non_current_indicator_ids.to_a) if params[:current_only] == "true"
    records
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_indicator
    @indicator = policy_scope(base_object).find(params[:id])
    authorize @indicator
  end

  def serialize(target, serializer: IndicatorSerializer)
    super
  end
end
