class RecommendationCategory < VersionedRecord
  belongs_to :recommendation, optional: true
  belongs_to :category, optional: true

  validates :category_id, uniqueness: {scope: :recommendation_id}
  validates :recommendation_id, presence: true
  validates :category_id, presence: true
  validate :single_category_per_taxonomy, on: :create

  validate :recommendation_must_exist, on: :create
  validate :category_must_exist, on: :create

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  # replacing "save": before creating the record we need to remove all
  # previous relationships (there should only be one) between the recommendation
  # and other categories of the same taxonomy
  # also we need to lock the recommendation to ensure that no other category is associated
  def save_with_cleanup
    if multiple_categories_allowed_for_taxonomy?
      return save!
    end

    if self.class.advisory_lock_exists?(lock_name)
      return false
    end

    self.class.with_advisory_lock(lock_name) do
      transaction do
        self.class.where(
          category_id: category.taxonomy.categories.where.not(id: category.id).pluck(:id),
          recommendation_id: recommendation_id
        ).destroy_all

        save!
      end
    end
  end

  private

  def recommendation_must_exist
    return if recommendation_id.blank?

    unless Recommendation.exists?(recommendation_id)
      errors.add(:recommendation, "must exist (id: #{recommendation_id})")
    end
  end

  def category_must_exist
    return if category_id.blank?

    unless Category.exists?(category_id)
      errors.add(:category, "must exist (id: #{category_id})")
    end
  end

  def lock_name
    "RecommendationCategory-recommendation_id_#{recommendation_id}-taxonomy_id_#{category.taxonomy_id}"
  end

  def multiple_categories_allowed_for_taxonomy?
    !category&.taxonomy || category&.taxonomy&.allow_multiple
  end

  def set_relationship_updated
    if recommendation && !recommendation.destroyed?
      recommendation.update_column(:relationship_updated_at, Time.zone.now)
      recommendation.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end

  def single_category_per_taxonomy
    if category&.taxonomy && !category.taxonomy.allow_multiple
      existing_categories = self.class.where(
        category_id: category.taxonomy.categories.pluck(:id),  # Ensure you're using IDs here
        recommendation_id: recommendation_id
      )

      if existing_categories.count >= 1
        errors.add(:category, "This recommendation already has a category in the same taxonomy. Multiple categories are not allowed for the taxonomy.")
      end
    end
  end
end
