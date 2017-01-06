class RecommendationCategory < ApplicationRecord
  belongs_to :recommendation
  belongs_to :category
  accepts_nested_attributes_for :recommendation
  accepts_nested_attributes_for :category
end
