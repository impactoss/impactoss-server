# frozen_string_literal: true

require "cgi"
require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "multi_factor_email" do
    let(:user) { FactoryBot.create(:user) }
    let(:otp_code) { "123456" }
    let(:mail) { UserMailer.multi_factor_email(user, otp_code) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your multi-factor authentication code")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["no-reply@mail.impactoss.org"])
    end

    it "mentions the user's name" do
      expect(mail.text_part.body).to match(user.name)
      expect(mail.html_part.body).to match(CGI.escapeHTML(user.name))
    end

    it "includes the OTP code in the body" do
      expect(mail.text_part.body).to match(otp_code)
      expect(mail.html_part.body).to match(otp_code)
    end

    it "mentions expiration time" do
      expect(mail.text_part.body).to match(/10 minutes/)
      expect(mail.html_part.body).to match(/10 minutes/)
    end

    it "includes security warning" do
      expect(mail.text_part.body).to match(/do not share/)
      expect(mail.html_part.body).to match(/do not share/)
    end
  end
end
