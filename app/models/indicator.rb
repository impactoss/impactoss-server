class Indicator < ApplicationRecord
  has_paper_trail

  validates :title, presence: true

  has_many :measure_indicators, inverse_of: :indicator
  has_many :progress_reports
  has_many :due_dates
  has_many :measures, through: :measure_indicators, inverse_of: :indicators
  has_many :categories, through: :measures
  has_many :recommendations, through: :measures

  belongs_to :manager, class_name: User, foreign_key: :manager_id, required: false

  validate :at_least_one_measure?

  accepts_nested_attributes_for :measure_indicators

  private

  def at_least_one_measure?
    errors.add(:measures, 'need at least one measure') if measure_indicators.empty?
  end
end
