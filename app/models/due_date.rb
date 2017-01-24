class DueDate < ApplicationRecord
  has_paper_trail

  belongs_to :indicator
  has_one :manager, through: :indicator

  validates :due_date, presence: true
end
