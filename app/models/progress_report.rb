class ProgressReport < ApplicationRecord
  belongs_to :indicator
  belongs_to :due_date, required: false
  has_many :measures, through: :indicator
  has_many :recommendations, through: :measures
  has_many :categories, through: :recommendations

  validates :title, presence: true
end
