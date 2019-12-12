class Taxonomy < VersionedRecord
  has_many :categories
  belongs_to :taxonomy, class_name: Taxonomy, foreign_key: :parent_id, optional: true
  has_many :taxonomies, class_name: Taxonomy, foreign_key: :parent_id

  validates :title, presence: true

  validates :allow_multiple, inclusion: [true, false]
  validates :tags_recommendations, inclusion: [true, false]
  validates :tags_measures, inclusion: [true, false]
end
