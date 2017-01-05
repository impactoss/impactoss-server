class TaxonomySerializer < ApplicationSerializer
  attributes :title, :tags_recommendations, :tags_measures, :draft

  has_many :categories
end
