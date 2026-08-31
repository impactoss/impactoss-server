# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Session inactivity timeout", type: :request do
  let(:password) { "SecurePassword123!" }
  let(:user) { FactoryBot.create(:user, password:, password_confirmation: password) }

  # Sign in for real to obtain a live token + its activity row.
  def sign_in_headers
    allow(Rails.application.config).to receive(:enable_mfa).and_return(false)
    post "/auth/sign_in", params: {email: user.email, password:}, as: :json
    expect(response).to have_http_status(:success)
    {
      "access-token" => response.headers["access-token"],
      "client" => response.headers["client"],
      "uid" => response.headers["uid"]
    }
  end

  describe "row lifecycle" do
    it "creates exactly one activity row per token at sign-in" do
      headers = sign_in_headers
      expect(user.token_activities.pluck(:client_id)).to eq([headers["client"]])
    end

    it "deletes the activity row on sign-out" do
      headers = sign_in_headers
      expect {
        delete "/auth/sign_out", headers:, as: :json
      }.to change { user.token_activities.count }.from(1).to(0)
    end

    it "prunes rows when max_number_of_devices is exceeded" do
      # max_number_of_devices = 2: a third client evicts the oldest token, and
      # its activity row must go with it.
      3.times { sign_in_headers }
      expect(user.token_activities.count).to eq(2)
      expect(user.reload.tokens.keys.sort).to eq(user.token_activities.pluck(:client_id).sort)
    end
  end

  describe "enforcement" do
    it "allows a request within the timeout window" do
      headers = sign_in_headers
      get "/bookmarks", headers:, as: :json
      expect(response).to have_http_status(:success)
    end

    it "rejects a request once the token is idle past the threshold" do
      headers = sign_in_headers
      user.token_activities.update_all(last_activity_at: (TokenActivity.inactivity_timeout + 1.minute).ago)

      get "/bookmarks", headers:, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "deletes the stale row on rejection (fail closed thereafter)" do
      headers = sign_in_headers
      user.token_activities.update_all(last_activity_at: (TokenActivity.inactivity_timeout + 1.minute).ago)

      get "/bookmarks", headers:, as: :json
      expect(user.token_activities.count).to eq(0)
    end

    it "fails closed when the activity row is missing" do
      headers = sign_in_headers
      user.token_activities.delete_all

      get "/bookmarks", headers:, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "drops the token from users.tokens on expiry, not just the activity row" do
      headers = sign_in_headers
      user.token_activities.update_all(last_activity_at: (TokenActivity.inactivity_timeout + 1.minute).ago)

      get "/bookmarks", headers:, as: :json
      expect(user.reload.tokens.keys).not_to include(headers["client"])
    end

    it "does not revive an expired session when another sign-in reconciles tokens" do
      headers = sign_in_headers
      user.token_activities.update_all(last_activity_at: (TokenActivity.inactivity_timeout + 1.minute).ago)

      get "/bookmarks", headers:, as: :json
      expect(response).to have_http_status(:unauthorized)

      # A second sign-in changes tokens, which is what actually triggers
      # User#reconcile_token_activities (guarded by saved_change_to_tokens?).
      # If the expired client were still in tokens, this would recreate its
      # activity row with a fresh window.
      sign_in_headers

      get "/bookmarks", headers:, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "heartbeat" do
    it "does not refresh on a normal (non-heartbeat) request" do
      headers = sign_in_headers
      original = user.token_activities.first.last_activity_at

      get "/bookmarks", headers:, as: :json
      expect(user.token_activities.first.last_activity_at).to be_within(1.second).of(original)
    end

    it "refreshes activity when stale beyond the coalesce window" do
      headers = sign_in_headers
      user.token_activities.update_all(last_activity_at: (TokenActivity.coalesce_window + 1.minute).ago)

      post "/auth/activity", headers:, as: :json
      expect(response).to have_http_status(:no_content)
      expect(user.token_activities.first.last_activity_at).to be_within(2.seconds).of(Time.current)
    end

    it "coalesces: does not rewrite within the coalesce window" do
      headers = sign_in_headers
      recent = 30.seconds.ago
      user.token_activities.update_all(last_activity_at: recent)

      post "/auth/activity", headers:, as: :json
      expect(response).to have_http_status(:no_content)
      expect(user.token_activities.first.last_activity_at).to be_within(1.second).of(recent)
    end

    it "cannot resurrect an already-expired session" do
      headers = sign_in_headers
      user.token_activities.update_all(last_activity_at: (TokenActivity.inactivity_timeout + 1.minute).ago)

      post "/auth/activity", headers:, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(user.token_activities.count).to eq(0)
    end
  end
end
