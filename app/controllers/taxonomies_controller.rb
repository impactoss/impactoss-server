class TaxonomiesController < ApplicationController
  def index
    @taxonomies = policy_scope(Taxonomy).order(created_at: :desc)
  end

  def show
    @taxonomy = Taxonomy.find(params[:id])
    authorize @taxonomy
  end
end
