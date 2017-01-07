# frozen_string_literal: true
class Recommendation < ApplicationRecord
  has_paper_trail

  has_many :recommendation_measures, inverse_of: :recommendation
  has_many :recommendation_categories, inverse_of: :recommendation
  has_many :measures, through: :recommendation_measures
  has_many :categories, through: :recommendation_categories
  has_many :indicators, through: :measures
  has_many :progress_reports, through: :indicators
  has_many :due_dates, through: :indicators

  accepts_nested_attributes_for :recommendation_categories

  validates :title, presence: true
  validates :number, presence: true
  validate :at_least_one_category?

  private

  def at_least_one_category?
    errors.add(:categories, 'need at least one category') if recommendation_categories.empty?
  end
end
