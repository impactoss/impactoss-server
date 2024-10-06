class MeasureCategory < VersionedRecord
  belongs_to :measure
  belongs_to :category
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :measure_id}
  validates :measure_id, presence: true
  validates :category_id, presence: true
  validate :single_category_per_taxonomy, on: :create

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  # replacing "save": before creating the record we need to remove all
  # previous relationships (there should only be one) between the measure
  # and other categories of the same taxonomy
  # also we need to lock the measure to ensure that no other category is associated
  def save_with_cleanup
    measure.with_lock do
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
  end

  private

  def set_relationship_updated
    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end

  def single_category_per_taxonomy
    if category&.taxonomy && !category.taxonomy.allow_multiple
      existing_categories = self.class.where(
        category_id: category.taxonomy.categories.pluck(:id),  # Ensure you're using IDs here
        measure_id: measure_id
      )

      if existing_categories.count >= 1
        errors.add(:category, "This measure already has a category in the same taxonomy. Multiple categories are not allowed for the taxonomy.")
      end
    end
  end
end
