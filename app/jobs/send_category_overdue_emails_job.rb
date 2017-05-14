class SendCategoryOverdueEmailsJob < ApplicationJob
  queue_as :default

  def perform()
    Category.send_all_overdue_emails
  end
end
