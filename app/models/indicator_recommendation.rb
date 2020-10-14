class IndicatorRecommendation < ApplicationRecord
  self.table_name = "indicators_recommendations"

  belongs_to :indicator
  belongs_to :recommendation

  #accepts_nested_attributes_for :indicator
  #accepts_nested_attributes_for :recommendation
end
