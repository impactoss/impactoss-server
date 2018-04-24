class Taxonomy < VersionedRecord
  has_many :categories

  validates :title, presence: true

  validates :allow_multiple, inclusion: [true, false]
  validates :tags_recommendations, inclusion: [true, false]
  validates :tags_measures, inclusion: [true, false]
end
