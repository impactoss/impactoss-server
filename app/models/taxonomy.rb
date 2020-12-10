class Taxonomy < VersionedRecord
  has_many :categories

  has_many :framework_taxonomies, inverse_of: :taxonomy, dependent: :destroy
  has_many :frameworks, through: :framework_taxonomies
  belongs_to :framework

  validates :title, presence: true

  validates :allow_multiple, inclusion: [true, false]
  validates :tags_measures, inclusion: [true, false]
end
