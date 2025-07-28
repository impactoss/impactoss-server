class RecommendationIndicator < VersionedRecord
  belongs_to :recommendation, inverse_of: :recommendation_indicators, optional: true
  belongs_to :indicator, inverse_of: :recommendation_indicators, optional: true

  validates :recommendation_id, presence: true
  validates :indicator_id, presence: true
  validate :recommendation_must_exist, on: :create
  validate :indicator_must_exist, on: :create

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def recommendation_must_exist
    return if recommendation_id.blank?

    unless Recommendation.exists?(recommendation_id)
      errors.add(:recommendation, "must exist (id: #{recommendation_id})")
    end
  end

  def indicator_must_exist
    return if indicator_id.blank?

    unless Indicator.exists?(indicator_id)
      errors.add(:indicator, "must exist (id: #{indicator_id})")
    end
  end

  def set_relationship_updated
    if recommendation && !recommendation.destroyed?
      recommendation.update_column(:relationship_updated_at, Time.zone.now)
      recommendation.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end

    if indicator && !indicator.destroyed?
      indicator.update_column(:relationship_updated_at, Time.zone.now)
      indicator.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
