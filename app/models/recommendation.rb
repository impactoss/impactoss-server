# frozen_string_literal: true
class Recommendation < VersionedRecord
  has_many :recommendation_measures, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_categories, inverse_of: :recommendation, dependent: :destroy
  has_many :sdgtarget_recommendations, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_indicators, inverse_of: :recommendation, dependent: :destroy

  has_many :measures, through: :recommendation_measures
  has_many :categories, through: :recommendation_categories
  has_many :indicators, through: :recommendation_indicators
  has_many :progress_reports, through: :indicators
  has_many :due_dates, through: :indicators

  has_many :recommendation_recommendations, :foreign_key => 'recommendation_id'
  has_many :recommendations, :through => :recommendation_recommendations, :source => :other_recommendation

  belongs_to :framework, optional: true

  accepts_nested_attributes_for :recommendation_categories

  validates :title, presence: true
  validates :reference, presence: true
end
