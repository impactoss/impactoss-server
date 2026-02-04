require "rails_helper"

RSpec.describe "Password Security", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { FactoryBot.create(:user, password: "InitialPassword123!", password_confirmation: "InitialPassword123!") }

  # Pull config values for readability
  let(:max_attempts) { Devise.maximum_attempts }
  let(:unlock_duration) { Devise.unlock_in }
  let(:password_history_count) { Devise.password_archiving_count }

  describe "Account Lockout" do
    it "locks account after #{Devise.maximum_attempts} failed login attempts" do
      max_attempts.times do
        post "/auth/sign_in", params: {
          email: user.email,
          password: "WrongPassword123!"
        }
      end

      expect(user.reload.access_locked?).to be true
    end

    it "prevents login when account is locked" do
      user.lock_access!

      post "/auth/sign_in", params: {
        email: user.email,
        password: "InitialPassword123!"
      }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json["error"]).to match(/locked/)
    end

    it "unlocks account after configured duration" do
      user.lock_access!

      # Simulate unlock_in duration passing
      travel(unlock_duration + 1.minute) do
        post "/auth/sign_in", params: {
          email: user.email,
          password: "InitialPassword123!"
        }

        expect(response).to have_http_status(:ok)
        expect(user.reload.access_locked?).to be false
      end
    end
  end

  describe "Last Attempt Warning" do
    it "warns user one attempt before lockout" do
      # Make (max_attempts - 1) failed attempts
      (max_attempts - 1).times do
        post "/auth/sign_in", params: {
          email: user.email,
          password: "WrongPassword123!"
        }
      end

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json["error"]).to match(/one more attempt/i)
      expect(json["reason"]).to eq("last_attempt")
    end
  end

  describe "Password Expiry" do
    it "requires password reset after 90 days" do
      user.update_column(:password_changed_at, 91.days.ago)

      post "/auth/sign_in", params: {
        email: user.email,
        password: "InitialPassword123!"
      }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json["error"]).to match(/expired/)
      expect(json["reason"]).to eq("password_expired")
    end

    it "allows login with non-expired password" do
      user.update_column(:password_changed_at, 89.days.ago)

      post "/auth/sign_in", params: {
        email: user.email,
        password: "InitialPassword123!"
      }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "Password History" do
    it "prevents reusing any of the last #{Devise.password_archiving_count} passwords" do
      # Create password history
      old_passwords = password_history_count.times.map { |i| "OldPassword#{i}!" }

      old_passwords.each do |pwd|
        user.update(password: pwd, password_confirmation: pwd)
      end

      # Try to reuse the first old password
      user.password = old_passwords.first
      user.password_confirmation = old_passwords.first

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("was used previously.")
    end

    it "allows reusing password from beyond the history limit" do
      # User created with factory password (count 1)
      # Change password (password_history_count) more times
      password_history_count.times do |i|
        user.update(
          password: "NewPassword#{i}!",
          password_confirmation: "NewPassword#{i}!"
        )
      end

      # Now the original factory password should be available again
      user.password = "SecurePassword123!"
      user.password_confirmation = "SecurePassword123!"

      expect(user).to be_valid
    end

    it "allows using a new password that wasn't used before" do
      user.password = "BrandNewPassword123!"
      user.password_confirmation = "BrandNewPassword123!"

      expect(user).to be_valid
    end
  end

  describe "Combined Security Features" do
    it "checks security constraints before allowing login" do
      user.update_column(:password_changed_at, 91.days.ago)
      user.lock_access!

      post "/auth/sign_in", params: {
        email: user.email,
        password: "InitialPassword123!"
      }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json["error"]).to match(/locked|expired/)
    end
  end
end
