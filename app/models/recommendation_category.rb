class RecommendationCategory < ApplicationRecord
  belongs_to :recommendation
  belongs_to :category
  accepts_nested_attributes_for :recommendation
  accepts_nested_attributes_for :category

  validates :category_id, uniqueness: { scope: :recommendation_id }
  validates :recommendation_id, presence: true
  validates :category_id, presence: true
end
