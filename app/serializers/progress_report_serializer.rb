class ProgressReportSerializer < ApplicationSerializer
  attributes :indicator_id, :due_date_id, :title, :description, :document_url, :document_public, :draft
end
