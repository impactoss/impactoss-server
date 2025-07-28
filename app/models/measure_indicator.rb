class MeasureIndicator < VersionedRecord
  belongs_to :measure, optional: true
  belongs_to :indicator, optional: true

  validates :measure_id, uniqueness: {scope: :indicator_id}
  validates :measure_id, presence: true
  validates :indicator_id, presence: true
  validate :measure_must_exist, on: :create
  validate :indicator_must_exist, on: :create

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def measure_must_exist
    return if measure_id.blank?

    unless Measure.exists?(measure_id)
      errors.add(:measure, "must exist (id: #{measure_id})")
    end
  end

  def indicator_must_exist
    return if indicator_id.blank?

    unless Indicator.exists?(indicator_id)
      errors.add(:indicator, "must exist (id: #{indicator_id})")
    end
  end

  def set_relationship_updated
    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end

    if indicator && !indicator.destroyed?
      indicator.update_column(:relationship_updated_at, Time.zone.now)
      indicator.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
