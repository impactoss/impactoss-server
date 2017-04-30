# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: 'donotreply@sadata.baran.co.nz'
  layout 'mailer'
end
