class MeasureCategory < VersionedRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :measure_id}
  validates :measure_id, presence: true
  validates :category_id, presence: true

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  # replacing "save": before creating the record we need to remove all
  # previous relationships (there should only be one) between the measure
  # and other categories of the same taxonomy
  def save_with_cleanup
    transaction do
      if category && category.taxonomy&.allow_multiple == false
        self.class.where(
          category_id: category.taxonomy.categories.where.not(id: category.id).pluck(:id),
          measure_id: measure_id
        ).destroy_all
      end

      save!
    end
  end

  private

  def set_relationship_updated
    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
