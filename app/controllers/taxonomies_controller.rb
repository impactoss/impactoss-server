class TaxonomiesController < ApplicationController
  before_action :set_and_authorize_taxonomy, only: [:show, :update, :destroy]

  # GET /taxonomies
  def index
    @taxonomies = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @taxonomies

    render json: serialize(@taxonomies)
  end

  # GET /taxonomies/1
  def show
    render json: serialize(@taxonomy)
  end

  # POST /taxonomies
  def create
    @taxonomy = Taxonomy.new
    @taxonomy.assign_attributes(permitted_attributes(@taxonomy))
    authorize @taxonomy

    if @taxonomy.save
      render json: serialize(@taxonomy), status: :created, location: @taxonomy
    else
      render json: @taxonomy.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /taxonomies/1
  def update
    if @taxonomy.update_attributes!(permitted_attributes(@taxonomy))
      set_and_authorize_taxonomy
      render json: serialize(@taxonomy)
    end
  end

  # DELETE /taxonomies/1
  def destroy
    @taxonomy.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_taxonomy
    @taxonomy = policy_scope(base_object).find(params[:id])
    authorize @taxonomy
  end

  def base_object
    Taxonomy
  end

  def serialize(target, serializer: TaxonomySerializer)
    super
  end
end
