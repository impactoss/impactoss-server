class IndicatorRecommendation < ApplicationRecord
  self.table_name = "indicators_recommendations"

  belongs_to :indicator
  belongs_to :recommendation
end
