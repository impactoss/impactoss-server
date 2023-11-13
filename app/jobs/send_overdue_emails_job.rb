class SendOverdueEmailsJob < ApplicationJob
  queue_as :default

  def perform
    DueDate.send_overdue_emails
  end
end
