class MeasureCategory < VersionedRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :measure_id}
  validates :measure_id, presence: true
  validates :category_id, presence: true

  after_commit :destroy_disallowed_sibling_categories, on: [:create, :update]
  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def destroy_disallowed_sibling_categories
    return unless category

    self.class.where(
      category_id: category.disallowed_sibling_category_ids,
      measure_id: measure_id
    ).destroy_all
  end

  def set_relationship_updated
    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
