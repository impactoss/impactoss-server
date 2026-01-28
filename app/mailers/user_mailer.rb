# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def multi_factor_email(user, otp_code)
    @user = user
    @otp_code = otp_code
    @client_url = ENV["CLIENT_URL"] || "https://undefined.client.url"

    mail to: user.email, subject: "Your multi-factor authentication code"
  end
end
