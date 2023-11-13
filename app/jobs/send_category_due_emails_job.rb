class SendCategoryDueEmailsJob < ApplicationJob
  queue_as :default

  def perform
    Category.send_all_due_emails
  end
end
