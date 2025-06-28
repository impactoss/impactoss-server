require File.expand_path("../config/boot", __FILE__)
require File.expand_path("../config/environment", __FILE__)
require "clockwork"

module Clockwork # leftovers:keep
  every(1.day, "Send Due Emails", at: "10:30", tz: Rails.application.config.time_zone) do
    SendDueEmailsJob.perform_now
  end

  every(1.day, "Send Overdue Emails", at: "9:15", tz: Rails.application.config.time_zone) do
    SendOverdueEmailsJob.perform_now
  end

  # Should this also have a call to send Category Due Emails?

  every(1.day, "Send Category Overdue Emails", at: "9:15", tz: Rails.application.config.time_zone) do
    SendCategoryOverdueEmailsJob.perform_now
  end

  every(1.day, "Send Progress Report Updated Emails", at: "00:00", tz: Rails.application.config.time_zone) do
    SendProgressReportUpdatedEmailsJob.perform_now
  end

  error_handler do |error|
  end
end
