class FrameworkTaxonomiesController < ApplicationController

  # GET /framework_taxonomies/:id
  def show
    @framework_taxonomy = policy_scope(base_object).find(params[:id])
    authorize @framework_taxonomy
    render json: serialize(@framework_taxonomy)
  end

  # GET /framework_taxonomies
  def index
    @framework_taxonomies = policy_scope(base_object).all
    authorize @framework_taxonomies
    render json: serialize(@framework_taxonomies)
  end

  private

  def base_object
    FrameworkTaxonomy
  end

  def serialize(target, serializer: FrameworkTaxonomySerializer)
    super
  end

end