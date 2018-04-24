class DueDateSerializer
  include FastApplicationSerializer

  attributes :due_date, :draft, :indicator_id, :due, :overdue, :has_progress_report

  set_type :due_dates
end
