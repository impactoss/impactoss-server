class RecommendationMeasure < ApplicationRecord
  belongs_to :recommendation, inverse_of: :recommendation_measures
  belongs_to :measure, inverse_of: :recommendation_measures
  accepts_nested_attributes_for :recommendation
  accepts_nested_attributes_for :measure

  validates :measure_id, uniqueness: { scope: :recommendation_id }
end
