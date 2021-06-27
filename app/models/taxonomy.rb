class Taxonomy < VersionedRecord
  has_many :categories
  belongs_to :taxonomy, class_name: 'Taxonomy', foreign_key: :parent_id, optional: true
  has_many :taxonomies, class_name: 'Taxonomy', foreign_key: :parent_id

  has_many :framework_taxonomies, inverse_of: :taxonomy, dependent: :destroy
  has_many :frameworks, through: :framework_taxonomies
  belongs_to :framework, optional: true

  validates :title, presence: true

  validates :allow_multiple, inclusion: [true, false]
  validates :tags_measures, inclusion: [true, false]

  validate :sub_relation

  def sub_relation
    if parent_id.present?
      parent_taxonomy = Taxonomy.find(parent_id)

      if (!parent_taxonomy.parent_id.nil?)
        errors.add(:parent_id, "Parent taxonomy is already a sub-taxonomy.")
      end
    end
  end

end
