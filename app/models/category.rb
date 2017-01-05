class Category < ApplicationRecord
  belongs_to :taxonomy
  has_many :recommendation_categories
  has_many :recommendations, through: :recommendation_categories
end
