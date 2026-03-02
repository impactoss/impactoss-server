# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  def reset_password_instructions(record, token, opts = {})
    @redirect_url = opts[:redirect_url] || ""
    @client_config = opts[:client_config] || "default"
    super
  end

  protected

  def headers_for(action, opts = {})
    super.except(:email, :provider, :redirect_url, :client_config)
  end
end
