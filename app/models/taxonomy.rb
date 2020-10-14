class Taxonomy < VersionedRecord
  has_many :categories

  has_many :frameworks_taxonomies, :class_name => 'FrameworkTaxonomy', inverse_of: :taxonomy, dependent: :destroy
  has_many :frameworks, through: :frameworks_taxonomies

  validates :title, presence: true

  validates :allow_multiple, inclusion: [true, false]
  validates :tags_measures, inclusion: [true, false]
end
