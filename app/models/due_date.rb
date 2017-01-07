class DueDate < ApplicationRecord
  belongs_to :indicator

  validates :due_date, presence: true
end
