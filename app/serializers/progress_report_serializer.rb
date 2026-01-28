class ProgressReportSerializer
  include FastVersionedSerializer

  attributes :indicator_id,
    :is_current,
    :description,
    :document_public,
    :document_url,
    :draft,
    :due_date_id,
    :is_archive,
    :title

  set_type :progress_reports
end
