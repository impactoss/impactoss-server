class DueDate < ApplicationRecord
  has_paper_trail

  belongs_to :indicator

  validates :due_date, presence: true
end
