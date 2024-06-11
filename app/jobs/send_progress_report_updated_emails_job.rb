class SendProgressReportUpdatedEmailsJob < ApplicationJob
  queue_as :default

  def perform
    ProgressReport.send_all_updated_emails
  end
end
