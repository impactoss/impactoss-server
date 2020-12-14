class RecommendationIndicator < ApplicationRecord
  belongs_to :recommendation
  belongs_to :indicator

  validates :recommendation_id, presence: true
  validates :indicator_id, presence: true
end
