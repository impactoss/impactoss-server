class TaxonomySerializer < ApplicationSerializer
  attributes :title, :tags_recommendations, :tags_measures

  has_many :categories
end
