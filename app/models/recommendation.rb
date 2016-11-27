# frozen_string_literal: true
class Recommendation < ApplicationRecord
  validates :title, presence: true
  validates :number, presence: true
  has_many :recommendation_measures
  has_many :measures, through: :recommendation_measures
end
