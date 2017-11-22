class Taxonomy < ApplicationRecord
  has_paper_trail

  has_many :categories

  validates :title, presence: true

  validates :allow_multiple, inclusion: [true, false]
  validates :tags_recommendations, inclusion: [true, false]
  validates :tags_measures, inclusion: [true, false]

  default_scope { includes(:versions) }
end
