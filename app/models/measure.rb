# frozen_string_literal: true
class Measure < ApplicationRecord
  has_many :recommendation_measures, inverse_of: :measure
  has_many :measure_categories, inverse_of: :measure
  has_many :measure_indicators, inverse_of: :measure

  has_many :recommendations, through: :recommendation_measures, inverse_of: :measures
  has_many :categories, through: :measure_categories, inverse_of: :measures
  has_many :indicators, through: :measure_indicators, inverse_of: :measures
  has_many :due_dates, through: :indicators
  has_many :progress_reports, through: :indicators

  accepts_nested_attributes_for :recommendation_measures
  accepts_nested_attributes_for :measure_categories

  validates :title, presence: true
  validate :at_least_one_recommendation?
  validate :at_least_one_category?

  private

  def at_least_one_recommendation?
    # We have to use recommendation_measures here instead of recommendation otherwise Rails will not save correctly.
    errors.add(:recommendations, 'need at least one recommendation') if recommendation_measures.empty?
  end

  def at_least_one_category?
    errors.add(:categories, 'need at least one category') if measure_categories.empty?
  end
end
