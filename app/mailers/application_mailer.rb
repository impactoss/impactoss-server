# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@impactoss.org'
  layout 'mailer'
end
