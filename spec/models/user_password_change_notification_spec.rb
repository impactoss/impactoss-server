# frozen_string_literal: true

require "rails_helper"

# Devise fires a password-change notification via an after_update on the user,
# gated on the encrypted password actually changing
# (config.send_password_change_notification). This pins that trigger: the
# notification mailer is invoked once on a password change and not on other
# updates.
#
# The mailer is stubbed (returning a delivery double) rather than rendered, so
# this asserts the trigger, not the email's content or delivery. Real rendering
# and delivery are covered on UAT.
RSpec.describe User, "password change notification", type: :model do
  let(:current_password) { "SecurePassword123!" }
  let(:new_password) { "SecurePassword456!" }

  let(:user) do
    FactoryBot.create(:user, password: current_password, password_confirmation: current_password)
  end

  # deliver / deliver_now both covered so this doesn't depend on which Devise
  # uses to send; with(user, any_args) tolerates the trailing opts hash.
  def stub_password_change_mail
    double(deliver: true, deliver_now: true)
  end

  it "sends a password-change notification when the password changes" do
    expect(CustomDeviseMailer).to receive(:password_change)
      .with(user, any_args).and_return(stub_password_change_mail)

    user.update!(password: new_password, password_confirmation: new_password)
  end

  it "does not send one on a non-password update" do
    expect(CustomDeviseMailer).not_to receive(:password_change)

    user.update!(name: "Renamed Person")
  end

  it "sends only once when a follow-up save leaves the password unchanged" do
    # Mirrors the reset flow, where the password-change save is followed by a
    # second save (setting allow_password_change = false) that must not re-notify.
    expect(CustomDeviseMailer).to receive(:password_change)
      .with(user, any_args).once.and_return(stub_password_change_mail)

    user.update!(password: new_password, password_confirmation: new_password)
    user.update!(name: "Renamed Person")
  end
end
