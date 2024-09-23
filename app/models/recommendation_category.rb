class RecommendationCategory < VersionedRecord
  belongs_to :recommendation
  belongs_to :category
  accepts_nested_attributes_for :recommendation
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: {scope: :recommendation_id}
  validates :recommendation_id, presence: true
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
        recommendation_id: recommendation_id
      ).destroy_all
    end
  end

  def set_relationship_updated
    if recommendation && !recommendation.destroyed?
      recommendation.update_column(:relationship_updated_at, Time.zone.now)
      recommendation.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
