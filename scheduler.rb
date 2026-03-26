require File.expand_path("../config/boot", __FILE__)
require File.expand_path("../config/environment", __FILE__)
require "clockwork"

module Clockwork
  every(1.week, "Send Due Emails", at: "Monday 10:30", tz: Rails.application.config.time_zone) do
    SendDueEmailsJob.perform_now
  end

  every(1.week, "Send Overdue Emails", at: "Monday 10:25", tz: Rails.application.config.time_zone) do
    SendOverdueEmailsJob.perform_now
  end

  every(1.week, "Send Category Overdue Emails", at: "Monday 10:20", tz: Rails.application.config.time_zone) do
    SendCategoryOverdueEmailsJob.perform_now
  end

  every(1.day, "Send Progress Report Updated Emails", at: "00:00", tz: Rails.application.config.time_zone) do
    SendProgressReportUpdatedEmailsJob.perform_now
  end

  error_handler do |error|
  end
end
