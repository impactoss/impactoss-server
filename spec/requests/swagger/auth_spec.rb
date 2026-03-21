require "swagger_helper"

RSpec.describe "Authentication API", type: :request do
  let(:user) { FactoryBot.create(:user, :admin, password: "Xk9#mP2$vL5!", password_confirmation: "Xk9#mP2$vL5!") }

  def auth_headers_for(user)
    user.create_new_auth_token
  end

  let(:"access-token") { nil }
  let(:client) { nil }
  let(:uid) { nil }

  # ──────────────────────────────────────────────
  # POST /auth/sign_in
  # ──────────────────────────────────────────────
  path "/auth/sign_in" do
    post "Sign in" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: {type: :string},
          password: {type: :string}
        },
        required: %w[email password]
      }

      response "200", "signed in successfully (MFA disabled)" do
        before { Rails.application.config.enable_mfa = false }
        after { Rails.application.config.enable_mfa = ENV["IMPACTOSS_REQUIRE_MFA"].present? }

        let(:credentials) { {email: user.email, password: "Xk9#mP2$vL5!"} }

        run_test! do |response|
          expect(response.headers["access-token"]).to be_present
          expect(response.headers["client"]).to be_present
          expect(response.headers["uid"]).to eq(user.email)
        end
      end

      response "202", "MFA required - OTP sent to email" do
        before { Rails.application.config.enable_mfa = true }
        after { Rails.application.config.enable_mfa = ENV["IMPACTOSS_REQUIRE_MFA"].present? }

        let(:credentials) { {email: user.email, password: "Xk9#mP2$vL5!"} }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["otp_required"]).to eq(true)
          expect(json["temp_token"]).to be_present
        end
      end

      response "401", "invalid credentials" do
        let(:credentials) { {email: user.email, password: "wrong"} }
        run_test!
      end
    end
  end

  # ──────────────────────────────────────────────
  # DELETE /auth/sign_out
  # ──────────────────────────────────────────────
  path "/auth/sign_out" do
    delete "Sign out" do
      tags "Authentication"
      security [{access_token: [], client: [], uid: []}]

      response "200", "signed out successfully" do
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        run_test!
      end

      response "404", "not signed in or invalid token" do
        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid" }

        run_test!
      end
    end
  end

  # ──────────────────────────────────────────────
  # GET /auth/validate_token
  # ──────────────────────────────────────────────
  path "/auth/validate_token" do
    get "Validate token" do
      tags "Authentication"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      response "200", "token is valid" do
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"]["id"]).to eq(user.id)
        end
      end

      response "401", "token is invalid or expired" do
        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid" }

        run_test!
      end
    end
  end

  # ──────────────────────────────────────────────
  # POST /auth/password
  # ──────────────────────────────────────────────
  path "/auth/password" do
    post "Request password reset" do
      description "Forgotten password flow: sends a password reset link to the user's email. No authentication required."
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :password_reset, in: :body, schema: {
        type: :object,
        properties: {
          email: {type: :string},
          redirect_url: {type: :string}
        },
        required: %w[email redirect_url]
      }

      response "200", "password reset email sent" do
        let(:password_reset) { {email: user.email, redirect_url: ENV.fetch("CLIENT_URL", "http://localhost:3000")} }
        run_test!
      end

      response "404", "email not found" do
        let(:password_reset) { {email: "nobody@example.com", redirect_url: ENV.fetch("CLIENT_URL", "http://localhost:3000")} }
        run_test!
      end
    end

    put "Reset password" do
      description "Forgotten password flow: sets a new password. Requires allow_password_change to be enabled via the password reset link, must be completed within the reset expiry window."
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :password_update, in: :body, schema: {
        type: :object,
        properties: {
          password: {type: :string},
          password_confirmation: {type: :string}
        },
        required: %w[password password_confirmation]
      }

      response "200", "password updated" do
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:password_update) { {password: "Xk9#mP2$vL54!", password_confirmation: "Xk9#mP2$vL54!"} }

        before do
          auth
          user.update_columns(allow_password_change: true, reset_password_sent_at: Time.current)
        end

        run_test!
      end

      response "422", "validation error (passwords don't match)" do
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:password_update) { {password: "Xk9#mP2$vL54!", password_confirmation: "Xk9#mP2$vL5x!"} }

        before do
          auth
          user.update_columns(allow_password_change: true, reset_password_sent_at: Time.current)
        end

        run_test!
      end

      response "403", "password change not permitted without reset flow" do
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:password_update) { {password: "Xk9#mP2$vL54!", password_confirmation: "Xk9#mP2$vL54!"} }

        run_test!
      end

      response "403", "password change expired" do
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:password_update) { {password: "Xk9#mP2$vL54!", password_confirmation: "Xk9#mP2$vL54!"} }

        before do
          auth
          user.update_columns(allow_password_change: true, reset_password_sent_at: 2.hours.ago)
        end

        run_test!
      end
    end
  end

  # ──────────────────────────────────────────────
  # PUT /auth
  # ──────────────────────────────────────────────
  path "/auth" do
    put "Update password (authenticated)" do
      description "Changes password for the currently logged-in user. Requires current password."
      tags "Authentication"
      consumes "application/json"
      produces "application/json"
      security [{access_token: [], client: [], uid: []}]

      parameter name: :account_update, in: :body, schema: {
        type: :object,
        properties: {
          current_password: {type: :string},
          password: {type: :string},
          password_confirmation: {type: :string}
        },
        required: %w[current_password password password_confirmation]
      }

      response "200", "password updated" do
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:account_update) { {current_password: "Xk9#mP2$vL5!", password: "Xk9#mP2$vL54!", password_confirmation: "Xk9#mP2$vL54!"} }

        run_test!
      end

      response "422", "current password is invalid" do
        let(:auth) { auth_headers_for(user) }
        let(:"access-token") { auth["access-token"] }
        let(:client) { auth["client"] }
        let(:uid) { auth["uid"] }
        let(:account_update) { {current_password: "wrongpassword", password: "Xk9#mP2$vL54!", password_confirmation: "Xk9#mP2$vL54!"} }

        run_test!
      end

      response "404", "not authenticated" do
        let(:"access-token") { "invalid" }
        let(:client) { "invalid" }
        let(:uid) { "invalid" }
        let(:account_update) { {current_password: "Xk9#mP2$vL5!", password: "Xk9#mP2$vL54!", password_confirmation: "Xk9#mP2$vL54!"} }

        run_test!
      end
    end
  end

  # ──────────────────────────────────────────────
  # POST /auth/verify_multi_factor
  # ──────────────────────────────────────────────
  path "/auth/verify_multi_factor" do
    post "Verify MFA code" do
      tags "Multi-Factor Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :mfa_params, in: :body, schema: {
        type: :object,
        properties: {
          temp_token: {type: :string},
          otp_code: {type: :string}
        },
        required: %w[temp_token otp_code]
      }

      response "200", "OTP verified, auth tokens issued" do
        before do
          @otp_code = user.generate_and_send_multi_factor_email!
          @temp_token = SecureRandom.urlsafe_base64(32)
          Rails.cache.write("otp_temp_token:#{@temp_token}", user.id, expires_in: 5.minutes)
        end

        let(:mfa_params) { {temp_token: @temp_token, otp_code: @otp_code} }

        run_test! do |response|
          expect(response.headers["access-token"]).to be_present
          expect(response.headers["client"]).to be_present
          expect(response.headers["uid"]).to eq(user.email)
        end
      end

      response "401", "invalid or expired OTP" do
        before do
          @temp_token = SecureRandom.urlsafe_base64(32)
          Rails.cache.write("otp_temp_token:#{@temp_token}", user.id, expires_in: 5.minutes)
          user.generate_and_send_multi_factor_email!
        end

        let(:mfa_params) { {temp_token: @temp_token, otp_code: "000000"} }
        run_test!
      end

      response "422", "missing required parameters" do
        let(:mfa_params) { {temp_token: ""} }
        run_test!
      end
    end
  end

  # ──────────────────────────────────────────────
  # POST /auth/resend_multi_factor
  # ──────────────────────────────────────────────
  path "/auth/resend_multi_factor" do
    post "Resend MFA code" do
      tags "Multi-Factor Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :resend_params, in: :body, schema: {
        type: :object,
        properties: {
          temp_token: {type: :string}
        },
        required: %w[temp_token]
      }

      response "200", "new OTP sent to email" do
        before do
          @temp_token = SecureRandom.urlsafe_base64(32)
          Rails.cache.write("otp_temp_token:#{@temp_token}", user.id, expires_in: 5.minutes)
        end

        let(:resend_params) { {temp_token: @temp_token} }
        run_test!
      end

      response "401", "invalid or expired temp token" do
        let(:resend_params) { {temp_token: "expired_or_invalid"} }
        run_test!
      end

      response "422", "missing temp_token" do
        let(:resend_params) { {} }
        run_test!
      end
    end
  end
end
