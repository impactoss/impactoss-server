# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Role changes require current password", type: :request do
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

  describe "POST /user_roles" do
    it "rejects without current_password" do
      headers = sign_in_headers

      expect {
        post "/user_roles",
          params: {user_role: {user_id: target.id, role_id: role.id}},
          headers:, as: :json
      }.not_to change(UserRole, :count)

      expect(response).to have_http_status(401)
    end

    it "allows with correct current_password" do
      headers = sign_in_headers

      expect {
        post "/user_roles",
          params: {current_password: password, user_role: {user_id: target.id, role_id: role.id}},
          headers:, as: :json
      }.to change(UserRole, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe "DELETE /user_roles/:id" do
    let!(:user_role) { UserRole.create!(user: target, role: role) }

    it "rejects without current_password" do
      headers = sign_in_headers

      expect {
        delete "/user_roles/#{user_role.id}", headers:, as: :json
      }.not_to change(UserRole, :count)

      expect(response).to have_http_status(401)
    end

    it "allows with correct current_password" do
      headers = sign_in_headers

      expect {
        delete "/user_roles/#{user_role.id}",
          params: {current_password: password}, headers:, as: :json
      }.to change(UserRole, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
