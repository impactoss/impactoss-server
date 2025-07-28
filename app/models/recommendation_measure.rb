class RecommendationMeasure < VersionedRecord
  belongs_to :recommendation, inverse_of: :recommendation_measures, optional: true
  belongs_to :measure, inverse_of: :recommendation_measures, optional: true

  validates :measure_id, uniqueness: {scope: :recommendation_id}
  validates :recommendation_id, presence: true
  validates :measure_id, presence: true
  validate :recommendation_must_exist, on: :create
  validate :measure_must_exist, on: :create

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def recommendation_must_exist
    return if recommendation_id.blank?

    unless Recommendation.exists?(recommendation_id)
      errors.add(:recommendation, "must exist (id: #{recommendation_id})")
    end
  end

  def measure_must_exist
    return if measure_id.blank?

    unless Measure.exists?(measure_id)
      errors.add(:measure, "must exist (id: #{measure_id})")
    end
  end

  def set_relationship_updated
    if recommendation && !recommendation.destroyed?
      recommendation.update_column(:relationship_updated_at, Time.zone.now)
      recommendation.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end

    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
