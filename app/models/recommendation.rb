# frozen_string_literal: true
class Recommendation < VersionedRecord
  has_many :recommendation_measures, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_categories, inverse_of: :recommendation, dependent: :destroy
  has_many :sdgtarget_recommendations, inverse_of: :recommendation, dependent: :destroy
  has_many :indicators_recommendations, :class_name => 'IndicatorRecommendation', inverse_of: :recommendation, dependent: :destroy

  has_many :measures, through: :recommendation_measures
  has_many :categories, through: :recommendation_categories
  has_many :indicators, through: :indicators_recommendations
  has_many :progress_reports, through: :indicators
  has_many :due_dates, through: :indicators

  has_many :children, class_name: 'Recommendation', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Recommendation', optional: true

  accepts_nested_attributes_for :recommendation_categories

  validates :title, presence: true
  validates :reference, presence: true
end
