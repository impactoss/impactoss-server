# frozen_string_literal: true
class Measure < ApplicationRecord
  has_many :recommendation_actions
  has_many :recommendations, through: :recommendation_actions
end
