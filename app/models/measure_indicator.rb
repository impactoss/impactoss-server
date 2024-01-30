class MeasureIndicator < ApplicationRecord
  belongs_to :measure
  belongs_to :indicator
  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :indicator

  validates :measure_id, uniqueness: {scope: :indicator_id}
  validates :measure_id, presence: true
  validates :indicator_id, presence: true

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

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
