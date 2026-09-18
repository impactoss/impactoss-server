# frozen_string_literal: true

require "rails_helper"

RSpec.describe "In-app password change requires current password", type: :request do
  let(:current_password) { "SecurePassword123!" }
  let(:new_password) { "SecurePassword456!" }

  let(:user) do
    FactoryBot.create(:user, password: current_password, password_confirmation: current_password)
  end

  def sign_in_headers
    allow(Rails.application.config).to receive(:enable_mfa).and_return(false)
    post "/auth/sign_in", params: {email: user.email, password: current_password}, as: :json
    expect(response).to have_http_status(:success)
    {
      "access-token" => response.headers["access-token"],
      "client" => response.headers["client"],
      "uid" => response.headers["uid"]
    }
  end

  it "rejects a password change without current_password" do
    headers = sign_in_headers

    put "/auth",
      params: {password: new_password, password_confirmation: new_password},
      headers: headers, as: :json

    expect(response).to have_http_status(422)
    expect(user.reload.valid_password?(current_password)).to be(true)
    expect(user.reload.valid_password?(new_password)).to be(false)
  end

  it "rejects a password change with an incorrect current_password" do
    headers = sign_in_headers

    put "/auth",
      params: {
        current_password: "WrongPassword999!",
        password: new_password,
        password_confirmation: new_password
      },
      headers: headers, as: :json

    expect(response).to have_http_status(422)
    expect(user.reload.valid_password?(current_password)).to be(true)
    expect(user.reload.valid_password?(new_password)).to be(false)
  end

  it "allows a password change with the correct current_password" do
    headers = sign_in_headers

    put "/auth",
      params: {
        current_password: current_password,
        password: new_password,
        password_confirmation: new_password
      },
      headers: headers, as: :json

    expect(response).to have_http_status(:success)
    expect(user.reload.valid_password?(new_password)).to be(true)
  end
end
