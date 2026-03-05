class TaxonomiesController < ApplicationController
  # GET /taxonomies
  def index
    @taxonomies = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @taxonomies

    render json: serialize(@taxonomies)
  end

  private

  def base_object
    Taxonomy
  end

  def serialize(target, serializer: TaxonomySerializer)
    super
  end
end
