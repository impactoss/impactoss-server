# frozen_string_literal: true
class Recommendation < ApplicationRecord
  has_many :recommendation_measures
  has_many :measures, through: :recommendation_measures
end
