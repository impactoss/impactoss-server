class RecommendationIndicator < VersionedRecord
  belongs_to :recommendation
  belongs_to :indicator

  validates :recommendation_id, presence: true
  validates :indicator_id, presence: true

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

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
