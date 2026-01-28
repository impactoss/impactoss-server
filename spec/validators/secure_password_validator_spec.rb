require "rails_helper"

RSpec.describe SecurePasswordValidator do
  let(:user) { User.new(email: "test@example.com", name: "John Doe") }

  describe "password complexity requirements" do
    it "requires at least 12 characters" do
      user.password = "Short1!"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 12 characters)")
    end

    it "requires uppercase letter" do
      user.password = "lowercase123!"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must include at least one uppercase letter")
    end

    it "requires lowercase letter" do
      user.password = "UPPERCASE123!"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must include at least one lowercase letter")
    end

    it "requires digit" do
      user.password = "NoDigitsHere!"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must include at least one digit")
    end

    it "requires special character" do
      user.password = "NoSpecial123"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must include at least one special character")
    end

    it "accepts valid strong password" do
      user.password = "ValidPassword123!"
      user.password_confirmation = "ValidPassword123!"
      expect(user).to be_valid
    end
  end

  describe "password content restrictions" do
    it "rejects password containing email username" do
      user.email = "john@example.com"
      user.password = "MyJohnPassword1!"
      user.password_confirmation = "MyJohnPassword1!"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("cannot contain your email address or parts of it")
    end

    it "rejects password containing name" do
      user.name = "John Smith"
      user.password = "MyJohnPassword1!"
      user.password_confirmation = "MyJohnPassword1!"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("cannot contain your name or parts of it")
    end

    it "accepts password without email or name parts" do
      user.email = "john@example.com"
      user.name = "John Smith"
      user.password = "SecureRandom123!"
      user.password_confirmation = "SecureRandom123!"
      expect(user).to be_valid
    end
  end
end
