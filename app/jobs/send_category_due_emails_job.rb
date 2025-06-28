# This is currently uncalled because it lacks an entry in Scheduler.rb
# Maybe we can delete it?
class SendCategoryDueEmailsJob < ApplicationJob # leftovers:keep
  queue_as :default

  def perform
    Category.send_all_due_emails
  end
end
