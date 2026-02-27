# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  protected

  def headers_for(action, opts = {})
    super.except("email", "provider", "redirect-url", "client-config")
  end
end
