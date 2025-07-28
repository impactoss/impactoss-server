# frozen_string_literal: true

class Recommendation < VersionedRecord
  has_many :recommendation_measures, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_categories, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_indicators, inverse_of: :recommendation, dependent: :destroy

  has_many :measures, through: :recommendation_measures
  has_many :categories, through: :recommendation_categories

  has_many :indicators_direct, through: :recommendation_indicators, source: :indicator
  has_many :indicators_via_measures, through: :measures, source: :indicators

  def indicator_ids
    (indicators_direct.pluck(:id) + indicators_via_measures.pluck(:id)).uniq
  end

  def indicators
    Indicator.where(id: indicator_ids)
  end

  def due_dates
    DueDate.where(indicator_id: indicator_ids)
  end

  def progress_reports
    ProgressReport.where(indicator_id: indicator_ids)
  end

  has_many :recommendation_recommendations, foreign_key: "recommendation_id"
  has_many :recommendations, through: :recommendation_recommendations, source: :other_recommendation

  belongs_to :framework, optional: true

  belongs_to :relationship_updated_by, class_name: "User", required: false

  validates :title, presence: true
  validates :reference, presence: true, uniqueness: true

  def is_current
    categories.none?(&:has_reporting_cycle_taxonomy?) ||
      categories.any?(&:is_current)
  end
end
