# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(
    ENV.fetch("ACTION_MAILER_FROM_EMAIL", "no-reply@mail.impactoss.org"),
    ENV.fetch("ACTION_MAILER_FROM_NAME", "IMPACT OSS Notifications")
  )
  layout "mailer"
end
