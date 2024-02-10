class RecommendationRecommendation < VersionedRecord
  belongs_to :recommendation, foreign_key: "recommendation_id"
  belongs_to :other_recommendation, foreign_key: "other_recommendation_id", class_name: "Recommendation"

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def set_relationship_updated
    if recommendation && !recommendation.destroyed?
      recommendation.update_column(:relationship_updated_at, Time.zone.now)
      recommendation.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end

    if other_recommendation && !other_recommendation.destroyed?
      other_recommendation.update_column(:relationship_updated_at, Time.zone.now)
      other_recommendation.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
