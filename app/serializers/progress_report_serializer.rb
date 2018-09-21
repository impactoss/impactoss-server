class ProgressReportSerializer
  include FastVersionedSerializer

  attributes :indicator_id, :due_date_id, :title, :description, :document_url, :document_public, :draft

  set_type :progress_reports
end
