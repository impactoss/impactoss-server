class Category < ApplicationRecord
  has_paper_trail

  belongs_to :taxonomy
  belongs_to :manager, class_name: User, foreign_key: :manager_id, optional: true, inverse_of: :categories
  has_many :recommendation_categories
  has_many :user_categories
  has_many :measure_categories
  has_many :recommendations, through: :recommendation_categories
  has_many :users, through: :user_categories
  has_many :measures, through: :measure_categories
  has_many :indicators, through: :recommendations
  has_many :progress_reports, through: :indicators
  has_many :due_dates, through: :indicators

  validates :title, presence: true
end
