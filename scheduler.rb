require File.expand_path('../config/boot',        __FILE__)
require File.expand_path('../config/environment', __FILE__)
require 'clockwork'

module Clockwork
  every(1.week, 'Send Due Emails', at: 'Monday 08:00') do
    SendDueEmailsJob.perform_now()
  end

  every(1.day, 'Send Overdue Emails', at: '08:00') do
    SendOverdueEmailsJob.perform_now()
  end

  every(1.day, 'Send Categorhy Overdue Emails', at: '08:00') do
    SendCategoryOverdueEmailsJob.perform_now()
  end

  error_handler do |error|
  end
end