# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Multi-Factor Authentication API", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:temp_token) { SecureRandom.urlsafe_base64(32) }
  let(:valid_otp_code) { user.generate_and_send_multi_factor_email! }

  before do
    # Enable MFA globally for these tests
    allow(Rails.application.config).to receive(:require_mfa).and_return(true)
    allow(Rails.application.config).to receive(:mfa_methods).and_return([:email_otp])
    Rails.cache.write("otp_temp_token:#{temp_token}", user.id, expires_in: 5.minutes)
  end

  describe "POST /auth/verify_multi_factor" do
    context "with valid temp_token and otp_code" do
      it "returns success status" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(response).to have_http_status(:success)
      end

      it "returns auth tokens in response headers" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(response.headers["access-token"]).to be_present
        expect(response.headers["client"]).to be_present
        expect(response.headers["uid"]).to eq(user.email)
      end

      it "returns user data in response body" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        json = JSON.parse(response.body)
        expect(json["data"]["email"]).to eq(user.email)
      end

      it "deletes the temp token from cache" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(Rails.cache.read("otp_temp_token:#{temp_token}")).to be_nil
      end

      it "clears multi_factor_email_code and multi_factor_email_code_sent_at" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        user.reload
        expect(user.multi_factor_email_code).to be_nil
        expect(user.multi_factor_email_code_sent_at).to be_nil
      end

      it "creates a valid token for the user" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(user.reload.tokens).not_to be_empty
      end
    end

    context "with invalid otp_code" do
      before do
        valid_otp_code # Generate OTP before testing invalid code
      end

      it "returns unauthorized status" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: "000000"}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: "000000"}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Invalid multi-factor code")
      end

      it "does not delete the temp token" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: "000000"}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(Rails.cache.read("otp_temp_token:#{temp_token}")).to eq(user.id)
      end
    end

    context "with expired temp_token" do
      it "returns unauthorized status" do
        post "/auth/verify_multi_factor",
          params: {temp_token: "invalid_token", otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        post "/auth/verify_multi_factor",
          params: {temp_token: "invalid_token", otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Invalid or expired temp token")
      end
    end

    context "with expired OTP" do
      before do
        valid_otp_code
        user.update_column(:multi_factor_email_code_sent_at, 11.minutes.ago)
      end

      it "returns unauthorized status" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token, otp_code: valid_otp_code}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Invalid multi-factor code")
      end
    end

    context "with missing params" do
      it "returns unprocessable_entity status" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(response).to have_http_status(422)
      end

      it "returns error message" do
        post "/auth/verify_multi_factor",
          params: {temp_token: temp_token}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("temp_token and otp_code are required")
      end
    end
  end

  describe "POST /auth/resend_multi_factor" do
    it "returns success status" do
      post "/auth/resend_multi_factor",
        params: {temp_token: temp_token}.to_json,
        headers: {"CONTENT_TYPE" => "application/json"}
      expect(response).to have_http_status(:ok)
    end

    it "generates and sends a new OTP" do
      expect {
        post "/auth/resend_multi_factor",
          params: {temp_token: temp_token}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "updates multi_factor_email_code_sent_at" do
      Timecop.freeze(Time.current) do
        post "/auth/resend_multi_factor",
          params: {temp_token: temp_token}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        user.reload
        expect(user.multi_factor_email_code_sent_at).to be_within(1.second).of(DateTime.current)
      end
    end

    it "returns success message" do
      post "/auth/resend_multi_factor",
        params: {temp_token: temp_token}.to_json,
        headers: {"CONTENT_TYPE" => "application/json"}
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Multi-factor code re-sent to your email")
    end

    context "with invalid temp_token" do
      it "returns unauthorized status" do
        post "/auth/resend_multi_factor",
          params: {temp_token: "invalid"}.to_json,
          headers: {"CONTENT_TYPE" => "application/json"}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
