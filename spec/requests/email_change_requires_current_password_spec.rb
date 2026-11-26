# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Email change requires current password", type: :request do
  let(:password) { "SecurePassword123!" }
  let(:admin) { FactoryBot.create(:user, :admin, password:, password_confirmation: password) }

  before do
    allow_any_instance_of(UserPolicy).to receive(:permitted_attributes)
      .and_return([:name, :email])
  end

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

  it "rejects an email change without current_password" do
    headers = sign_in_headers

    put "/users/#{admin.id}",
      params: {user: {email: "new@example.com"}}, headers:, as: :json

    expect(response).to have_http_status(401)
    expect(admin.reload.email).not_to eq("new@example.com")
  end

  it "allows an email change with correct current_password" do
    headers = sign_in_headers

    put "/users/#{admin.id}",
      params: {current_password: password, user: {email: "new@example.com"}},
      headers:, as: :json

    expect(response).to have_http_status(:success)
    expect(admin.reload.email).to eq("new@example.com")
  end

  it "does not require current_password for a name-only update" do
    headers = sign_in_headers

    put "/users/#{admin.id}",
      params: {user: {name: "New Name"}}, headers:, as: :json

    expect(response).to have_http_status(:success)
    expect(admin.reload.name).to eq("New Name")
  end
end
