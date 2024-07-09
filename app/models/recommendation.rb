# frozen_string_literal: true

class Recommendation < VersionedRecord
  has_many :recommendation_measures, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_categories, inverse_of: :recommendation, dependent: :destroy
  has_many :sdgtarget_recommendations, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_indicators, inverse_of: :recommendation, dependent: :destroy

  has_many :measures, through: :recommendation_measures
  has_many :categories, through: :recommendation_categories
  has_many :indicators, through: :recommendation_indicators
  has_many :indicators_via_measures, through: :measures, source: :indicators
  has_many :progress_reports, through: :indicators
  has_many :due_dates, through: :indicators

  has_many :recommendation_recommendations, foreign_key: "recommendation_id"
  has_many :recommendations, through: :recommendation_recommendations, source: :other_recommendation

  belongs_to :framework, optional: true

  belongs_to :relationship_updated_by, class_name: "User", required: false

  accepts_nested_attributes_for :recommendation_categories

  validates :title, presence: true
  validates :reference, presence: true, uniqueness: true

  def is_current
    reporting_cycle_taxonomy = Taxonomy.joins(:taxonomy).where(has_date: true).where(taxonomies_taxonomies: {priority: 1}).first
    return true if reporting_cycle_taxonomy.nil? || categories.none? { _1.taxonomy_id == reporting_cycle_taxonomy.id }

    current_category = reporting_cycle_taxonomy.categories.order(Arel.sql("COALESCE(date, created_at) DESC")).first
    categories.include?(current_category)
  end
end
