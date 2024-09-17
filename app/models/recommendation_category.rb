class RecommendationCategory < VersionedRecord
  belongs_to :recommendation
  belongs_to :category
  accepts_nested_attributes_for :recommendation
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :recommendation_id}
  validates :recommendation_id, presence: true
  validates :category_id, presence: true

  after_commit :enforce_allow_multiple_from_taxonomy, on: [:create, :update]
  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def disallow_multiple
    RecommendationCategory
      .joins(category: :taxonomy)
      .where({
        recommendation_id: recommendation_id,
        category: {
          taxonomies: {allow_multiple: false}
        }
      })
      .count > 0
  end

  def enforce_allow_multiple_from_taxonomy
    if disallow_multiple
      other_recommendation_categories_on_recommendation.destroy_all
    end
  end

  def other_recommendation_categories_on_recommendation
    RecommendationCategory.where(recommendation_id: recommendation_id).where.not(category_id: category_id)
  end

  def set_relationship_updated
    if recommendation && !recommendation.destroyed?
      recommendation.update_column(:relationship_updated_at, Time.zone.now)
      recommendation.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
