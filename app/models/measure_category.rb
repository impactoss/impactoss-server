class MeasureCategory < VersionedRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :measure_id}
  validates :measure_id, presence: true
  validates :category_id, presence: true

  around_save :enforce_allow_multiple
  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def enforce_allow_multiple
    yield and return unless category && category.taxonomy&.allow_multiple == false

    transaction do
      yield
      self.class.where(
        category_id: category.taxonomy.categories.where.not(id: category_id).pluck(:id),
        measure_id: measure_id
      ).destroy_all
    end
  end

  def set_relationship_updated
    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
