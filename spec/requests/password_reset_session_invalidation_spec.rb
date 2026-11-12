# frozen_string_literal: true

require "rails_helper"

# driving a real password reset through the DTA
# endpoints must leave the session that COMPLETED the reset usable while
# invalidating a pre-existing (potentially hijacked) session.
#
# The model spec covers the prune logic in isolation; this covers the actual
# reset route - the PasswordsController subclass gate plus the edit -> update
# flow that mints the completing session's token. Scope is deliberately narrow:
# it asserts only the invalidation outcome (old token dead, completing token
# alive), not DTA's reset mechanics.
#
# Relies on config.remove_tokens_after_password_reset = true, and on token
# rotation being off (change_headers_on_each_request = false) so the completing
# session's headers stay valid after the update.
RSpec.describe "Password reset session invalidation", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:current_password) { "SecurePassword123!" }
  let(:new_password) { "SecurePassword456!" }
  let(:redirect_url) { "http://localhost" } # host allowed by redirect_options

  let(:user) do
    FactoryBot.create(:user, password: current_password, password_confirmation: current_password)
  end

  def auth_headers_from(source)
    {
      "access-token" => source["access-token"],
      "client" => source["client"],
      "uid" => source["uid"]
    }
  end

  # A real pre-existing session (the one that should be invalidated). MFA is
  # stubbed off so sign-in returns tokens directly, mirroring the session-timeout
  # spec's helper.
  def sign_in_and_capture_headers
    allow(Rails.application.config).to receive(:enable_mfa).and_return(false)
    post "/auth/sign_in", params: {email: user.email, password: current_password}, as: :json
    expect(response).to have_http_status(:success)
    auth_headers_from(response.headers)
  end

  it "invalidates a pre-existing session and keeps the reset-completing session" do
    old_session = sign_in_and_capture_headers

    # remove_tokens_after_password_reset keeps max_by(expiry), and expiry has
    # per-second granularity. In production the reset happens meaningfully later
    # than the pre-existing sign-in, so the completing token's expiry is strictly
    # greater and it is the one retained. Advance the clock so that holds here
    # too: without a gap both tokens land in the same expiry second and the tie
    # resolves to the OLDER (first-inserted) token, dropping the wrong session.
    travel 1.minute do
      # Seed the reset directly: returns the raw token, sets reset_password_sent_at,
      # sends no mail. Keeps the test off the mailer and focused on invalidation
      # rather than re-testing the /auth/password create endpoint.
      raw_reset_token = user.reload.send(:set_reset_password_token)

      # edit mints the completing session's token and sets allow_password_change;
      # the token is handed back in the redirect URL (query, or fragment on some
      # DTA paths - handle both).
      get "/auth/password/edit", params: {reset_password_token: raw_reset_token, redirect_url: redirect_url}
      expect(response).to have_http_status(:redirect)
      location = URI.parse(response.location)
      completing_session = auth_headers_from(Rack::Utils.parse_query(location.query || location.fragment))

      # Complete the reset, authenticated as the completing session.
      put "/auth/password",
        params: {password: new_password, password_confirmation: new_password},
        headers: completing_session, as: :json
      expect(response).to have_http_status(:success)

      # Old session is now dead...
      get "/bookmarks", headers: old_session, as: :json
      expect(response).to have_http_status(:unauthorized)

      # ...and the reset-completing session still works.
      get "/bookmarks", headers: completing_session, as: :json
      expect(response).to have_http_status(:success)
    end
  end
end
