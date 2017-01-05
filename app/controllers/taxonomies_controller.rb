class TaxonomiesController < ApplicationController
  before_action :set_and_authorize_taxonomy, only: [:show, :update, :destroy]

  # GET /taxonomies
  def index
    @taxonomies = policy_scope(Taxonomy).order(created_at: :desc).page(params[:page])
    authorize @taxonomies

    render json: @taxonomies
  end

  # GET /taxonomies/1
  def show
    render json: @taxonomy
  end

  # POST /taxonomies
  def create
    @taxonomy = Taxonomy.new
    @taxonomy.assign_attributes(permitted_attributes(@taxonomy))
    authorize @taxonomy

    if @taxonomy.save
      render json: @taxonomy, status: :created, location: @taxonomy
    else
      render json: @taxonomy.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /taxonomies/1
  def update
    render json: @taxonomy if @taxonomy.update_attributes!(permitted_attributes(@taxonomy))
  end

  # DELETE /taxonomies/1
  def destroy
    @taxonomy.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_taxonomy
    @taxonomy = policy_scope(Taxonomy).find(params[:id])
    authorize @taxonomy
  end
end
