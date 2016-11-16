# frozen_string_literal: true
class RecommendationAction < ApplicationRecord
  belongs_to :recommendation
  belongs_to :action
end
