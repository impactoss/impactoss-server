require "rails_helper"

RSpec.describe "GET /auth/password/edit", type: :request do
  before { allow(ENV).to receive(:fetch).and_call_original }

  it "redirects an invalid reset token to the configured invalid-link page" do
    allow(ENV).to receive(:fetch).with("CLIENT_URL", anything).and_return("https://example.com")
    allow(ENV).to receive(:fetch).with("CLIENT_RESET_LINK_INVALID_PATH", "not-found").and_return("reset-link-invalid")

    get "/auth/password/edit", params: {
      reset_password_token: "invalid",
      redirect_url: "https://example.com"
    }

    expect(response).to redirect_to("https://example.com/reset-link-invalid")
  end

  it "falls back to the default path when the var is unset" do
    allow(ENV).to receive(:fetch).with("CLIENT_URL", anything).and_return("https://example.com")

    get "/auth/password/edit", params: {
      reset_password_token: "invalid",
      redirect_url: "https://example.com"
    }
    expect(response).to redirect_to("https://example.com/not-found")
  end
end
