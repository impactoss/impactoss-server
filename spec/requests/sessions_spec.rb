# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions API", type: :request do
  describe "POST /auth/sign_in" do
    let(:password) { "SecurePassword123!" }
    let(:user) { FactoryBot.create(:user, password: password, password_confirmation: password) }

    context "when MFA is enabled globally" do
      before do
        allow(Rails.application.config).to receive(:enable_mfa).and_return(true)
      end

      it "returns accepted status" do
        post "/auth/sign_in", params: {email: user.email, password: password}, as: :json
        expect(response).to have_http_status(:accepted)
      end

      it "returns otp_required flag" do
        post "/auth/sign_in", params: {email: user.email, password: password}, as: :json
        json = JSON.parse(response.body)
        expect(json["otp_required"]).to be true
      end

      it "returns a temp_token" do
        post "/auth/sign_in", params: {email: user.email, password: password}, as: :json
        json = JSON.parse(response.body)
        expect(json["temp_token"]).to be_present
      end

      it "sends an OTP email" do
        expect {
          post "/auth/sign_in", params: {email: user.email, password: password}, as: :json
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "does not return auth tokens in headers" do
        post "/auth/sign_in", params: {email: user.email, password: password}, as: :json
        expect(response.headers["access-token"]).to be_blank
      end
    end

    context "when MFA is disabled globally" do
      before do
        allow(Rails.application.config).to receive(:enable_mfa).and_return(false)
      end

      it "returns success status" do
        post "/auth/sign_in", params: {email: user.email, password: password}, as: :json
        expect(response).to have_http_status(:success)
      end

      it "returns auth tokens in headers" do
        post "/auth/sign_in", params: {email: user.email, password: password}, as: :json
        expect(response.headers["access-token"]).to be_present
        expect(response.headers["client"]).to be_present
        expect(response.headers["uid"]).to eq(user.email)
      end

      it "does not send an OTP email" do
        expect {
          post "/auth/sign_in", params: {email: user.email, password: password}, as: :json
        }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized status" do
        post "/auth/sign_in", params: {email: user.email, password: "wrong_password"}, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not send an OTP email" do
        expect {
          post "/auth/sign_in", params: {email: user.email, password: "wrong_password"}, as: :json
        }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context "with non-existent user" do
      it "returns unauthorized status" do
        post "/auth/sign_in", params: {email: "nonexistent@example.com", password: password}, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
