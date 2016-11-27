# frozen_string_literal: true
class Measure < ApplicationRecord
  validates :title, presence: true
  has_many :recommendation_measures
  has_many :recommendations, through: :recommendation_measures
end
