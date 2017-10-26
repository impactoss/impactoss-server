# frozen_string_literal: true
class Measure < ApplicationRecord
  has_paper_trail

  has_many :recommendation_measures, inverse_of: :measure, dependent: :destroy
  has_many :sdgtarget_measures, inverse_of: :measure, dependent: :destroy
  has_many :measure_categories, inverse_of: :measure, dependent: :destroy
  has_many :measure_indicators, inverse_of: :measure, dependent: :destroy

  has_many :recommendations, through: :recommendation_measures, inverse_of: :measures
  has_many :categories, through: :measure_categories, inverse_of: :measures
  has_many :indicators, through: :measure_indicators, inverse_of: :measures
  has_many :due_dates, through: :indicators
  has_many :progress_reports, through: :indicators

  accepts_nested_attributes_for :recommendation_measures
  accepts_nested_attributes_for :measure_categories

  validates :title, presence: true

  default_scope { includes(:versions) }
end
