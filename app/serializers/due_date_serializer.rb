class DueDateSerializer < ApplicationSerializer
  attributes :due_date, :draft

  has_one :indicator
end
