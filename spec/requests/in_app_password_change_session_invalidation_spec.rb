# frozen_string_literal: true

require "rails_helper"

# In-app password change (PUT /auth) must invalidate the user's OTHER sessions
# while keeping the session that made the change signed in. The controller keeps
# only the current request's token and drops the rest before the change is
# saved, so the surviving session is the one performing the change - not merely
# the newest token by expiry.
RSpec.describe "In-app password change session invalidation", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:current_password) { "SecurePassword123!" }
  let(:new_password) { "SecurePassword456!" }

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

  # MFA stubbed off so sign-in returns tokens directly, mirroring the
  # session-timeout spec's helper. Each call is a fresh session for the user.
  def sign_in_and_capture_headers
    allow(Rails.application.config).to receive(:enable_mfa).and_return(false)
    post "/auth/sign_in", params: {email: user.email, password: current_password}, as: :json
    expect(response).to have_http_status(:success)
    auth_headers_from(response.headers)
  end

  def change_password(headers)
    put "/auth",
      params: {
        current_password: current_password,
        password: new_password,
        password_confirmation: new_password
      },
      headers: headers, as: :json
  end

  it "keeps the changing session and invalidates another session" do
    changing_session = sign_in_and_capture_headers
    other_session = sign_in_and_capture_headers

    change_password(changing_session)
    expect(response).to have_http_status(:success)

    get "/bookmarks", headers: changing_session, as: :json
    expect(response).to have_http_status(:success)

    get "/bookmarks", headers: other_session, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "keeps the changing session even when the other session is newer" do
    changing_session = sign_in_and_capture_headers

    # Sign the other session in later so its token expiry is strictly greater.
    # Keeping the current session must not depend on expiry order: a plain
    # keep-newest would retain this newer session and drop the one making the
    # change.
    travel 1.minute do
      other_session = sign_in_and_capture_headers

      change_password(changing_session)
      expect(response).to have_http_status(:success)

      get "/bookmarks", headers: changing_session, as: :json
      expect(response).to have_http_status(:success)

      get "/bookmarks", headers: other_session, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # The controller reshapes @resource.tokens BEFORE super, so the invalidation is
  # only ever persisted by the password-change save itself. A rejected change
  # never saves, leaving the reshape in memory and the other sessions alive.
  #
  # That holds today because nothing else in the request saves @resource
  # (update_auth_header is skipped on this controller). Pinned here because a
  # future callback that does save would silently sign every other device out on
  # a mistyped current password. 
  it "does not invalidate other sessions when the change is rejected" do
    changing_session = sign_in_and_capture_headers
    other_session = sign_in_and_capture_headers

    put "/auth", params: {current_password: "wrong", password: new_password,
      password_confirmation: new_password}, headers: changing_session, as: :json
    expect(response).to have_http_status(:unprocessable_content)

    get "/bookmarks", headers: other_session, as: :json
    expect(response).to have_http_status(:success)
  end
end
