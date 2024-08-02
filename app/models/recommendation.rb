# frozen_string_literal: true

class Recommendation < VersionedRecord
  has_many :recommendation_measures, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_categories, inverse_of: :recommendation, dependent: :destroy
  has_many :sdgtarget_recommendations, inverse_of: :recommendation, dependent: :destroy
  has_many :recommendation_indicators, inverse_of: :recommendation, dependent: :destroy

  has_many :measures, through: :recommendation_measures
  has_many :categories, through: :recommendation_categories
  has_many :indicators, through: :recommendation_indicators
  has_many :indicators_via_measures, through: :measures, source: :indicators
  has_many :progress_reports, through: :indicators
  has_many :due_dates, through: :indicators

  has_many :recommendation_recommendations, foreign_key: "recommendation_id"
  has_many :recommendations, through: :recommendation_recommendations, source: :other_recommendation

  belongs_to :framework, optional: true

  belongs_to :relationship_updated_by, class_name: "User", required: false

  accepts_nested_attributes_for :recommendation_categories

  validates :title, presence: true
  validates :reference, presence: true, uniqueness: true

  SUPPORT_LEVELS = {
    "noted" => 0,
    "supported_in_part" => 1,
    "supported" => 2
  }
  enum support_level: SUPPORT_LEVELS

  # This approach prevents the validation process being aborted by an ArgumentError.
  # Better enum validation exists in Rails 7.1 so we can replace this when we reach that version.
  def support_level=(value)
    if !SUPPORT_LEVELS.key?(value)
      @invalid_support_level = true
      return
    end

    super(value)
  end
  validate do
    if @invalid_support_level
      errors.add(:support_level, "is not a valid support_level. Valid options: #{SUPPORT_LEVELS.keys.join(", ")}")
    end
  end
end
