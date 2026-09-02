# frozen_string_literal: true

class Measure < VersionedRecord
  # No ResetsCurrentCycle here: the resolver never reads a Measure attribute,
  # only RecommendationMeasure rows (see current_cycle.rb), which invalidate
  # it on create and on destroy of the join record itself - reassigning
  # `recommendations=` removes stale join rows via delete_all, which fires
  # neither, so that path relies on nothing already having warmed the
  # resolver in the same unit of work.

  has_many :recommendation_measures, inverse_of: :measure, dependent: :destroy
  has_many :measure_categories, inverse_of: :measure, dependent: :destroy
  has_many :measure_indicators, inverse_of: :measure, dependent: :destroy

  has_many :recommendations, through: :recommendation_measures, inverse_of: :measures
  has_many :categories, through: :measure_categories, inverse_of: :measures
  has_many :indicators, through: :measure_indicators, inverse_of: :measures
  has_many :due_dates, through: :indicators
  has_many :progress_reports, through: :indicators

  belongs_to :parent, class_name: "Measure", required: false

  belongs_to :relationship_updated_by, class_name: "User", required: false

  validates :title, presence: true
  validates :reference, presence: true, uniqueness: true

  # Current with no recommendations, or when any of them is current.
  def is_current
    Current.cycle.measure_current?(id)
  end
end
