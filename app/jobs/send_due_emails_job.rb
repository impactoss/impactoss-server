class SendDueEmailsJob < ApplicationJob
  queue_as :default

  def perform()
    DueDate.send_due_emails
  end
end
