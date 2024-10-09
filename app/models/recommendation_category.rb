class RecommendationCategory < VersionedRecord
  belongs_to :recommendation
  belongs_to :category
  accepts_nested_attributes_for :recommendation
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :recommendation_id}
  validates :recommendation_id, presence: true
  validates :category_id, presence: true
  validate :single_category_per_taxonomy, on: :create

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  # replacing "save": before creating the record we need to remove all
  # previous relationships (there should only be one) between the recommendation
  # and other categories of the same taxonomy
  # also we need to lock the recommendation to ensure that no other category is associated
  def save_with_cleanup
    with_locked_recommendation do
      transaction do
        if category && category.taxonomy&.allow_multiple == false
          self.class.where(
            category_id: category.taxonomy.categories.where.not(id: category.id).pluck(:id),
            recommendation_id: recommendation_id
          ).destroy_all
        end

        save!
      end
    end
  end

  private

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

  def with_locked_recommendation
    if recommendation
      recommendation.with_lock do
        yield
      end
    else
      yield
    end
  end
end
