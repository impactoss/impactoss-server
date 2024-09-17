class MeasureCategory < VersionedRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :measure_id}
  validates :measure_id, presence: true
  validates :category_id, presence: true

  after_commit :enforce_allow_multiple_from_taxonomy, on: [:create, :update]
  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def disallow_multiple?
    self.class
      .joins(category: :taxonomy)
      .where({
        measure_id: measure_id,
        category: {
          taxonomies: {allow_multiple: false}
        }
      })
      .count > 0
  end

  def enforce_allow_multiple_from_taxonomy
    if disallow_multiple?
      others_on_measure.destroy_all
    end
  end

  def others_on_measure
    self.class.where(measure_id: measure_id).where.not(category_id: category_id)
  end

  def set_relationship_updated
    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
