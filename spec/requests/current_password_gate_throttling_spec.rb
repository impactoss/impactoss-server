# frozen_string_literal: true

require "rails_helper"

# The re-authentication gate (ApplicationController#require_current_password!)
# routes failures through Devise's valid_for_authentication?, so a wrong
# current_password counts toward :lockable. Without that it would be an
# unthrottled password oracle, usable even while the account is locked out of
# sign-in. Exercised here via POST /user_roles; the gate is shared with
# UsersController#update.
RSpec.describe "Current password gate throttling", type: :request do
  let(:password) { "SecurePassword123!" }
  let(:admin) { FactoryBot.create(:user, :admin, password:, password_confirmation: password) }
  let(:target) { FactoryBot.create(:user) }
  let(:role) { FactoryBot.create(:role, :contributor) }

  def sign_in_headers
    allow(Rails.application.config).to receive(:enable_mfa).and_return(false)
    post "/auth/sign_in", params: {email: admin.email, password:}, as: :json
    expect(response).to have_http_status(:success)
    {
      "access-token" => response.headers["access-token"],
      "client" => response.headers["client"],
      "uid" => response.headers["uid"]
    }
  end

  # Signed in once, then reused: a fresh sign-in would reset failed_attempts
  # via Warden's after_set_user hook and mask the counting under test.
  let!(:headers) { sign_in_headers }

  def attempt(current_password)
    post "/user_roles",
      params: {current_password:, user_role: {user_id: target.id, role_id: role.id}},
      headers:, as: :json
  end

  it "counts a wrong current_password toward lockout" do
    attempt("WrongPassword999!")

    expect(response).to have_http_status(401)
    expect(admin.reload.failed_attempts).to eq(1)
  end

  it "locks the account after maximum_attempts" do
    Devise.maximum_attempts.times { attempt("WrongPassword999!") }

    expect(admin.reload).to be_access_locked
  end

  it "rejects a correct current_password while locked" do
    admin.lock_access!

    expect { attempt(password) }.not_to change(UserRole, :count)

    expect(response).to have_http_status(401)
  end

  it "resets failed_attempts on success" do
    admin.update_column(:failed_attempts, 2)

    attempt(password)

    expect(response).to have_http_status(:created)
    expect(admin.reload.failed_attempts).to eq(0)
  end

  it "does not count a missing current_password" do
    post "/user_roles",
      params: {user_role: {user_id: target.id, role_id: role.id}},
      headers:, as: :json

    expect(response).to have_http_status(401)
    expect(admin.reload.failed_attempts).to eq(0)
  end
end
