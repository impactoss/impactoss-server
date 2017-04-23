class DueDateSerializer < ApplicationSerializer
  attributes :due_date, :draft, :indicator_id, :due, :overdue, :has_progress_report
end
