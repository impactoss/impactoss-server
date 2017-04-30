# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: 'donotreply@undp-sadata-staging.herokuapp.com'
  layout 'mailer'
end
