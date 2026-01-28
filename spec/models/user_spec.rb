# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject { FactoryBot.create(:user) }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to have_many :roles }
  it { is_expected.to have_many :managed_categories }
  it { is_expected.to have_many :categories }
  it { is_expected.to have_many :managed_indicators }

  it "configures paper_trail to particular fields" do
    expect(described_class.paper_trail_options).to include(ignore: ["tokens", "updated_at"])
  end

  it "is valid" do
    expect(subject).to be_valid
  end

  it "is invalid without a matching password" do
    subject.assign_attributes(
      password: "abc123",
      password_confirmation: "abc"
    )

    expect(subject).not_to be_valid
  end

  it "is_expected.to accept a role" do
    expect(subject.role?("the_role")).to be false

    subject.roles << Role.new(name: "the_role", friendly_name: "bla")

    expect(subject.role?("the_role")).to be true
  end

  describe "multi-factor authentication" do
    let(:user) { FactoryBot.create(:user, :with_multi_factor_email) }

    describe "#generate_and_send_multi_factor_email!" do
      it "generates a 6-digit OTP code" do
        code = user.generate_and_send_multi_factor_email!
        expect(code).to match(/^\d{6}$/)
      end

      it "stores encrypted OTP in multi_factor_email_code column" do
        code = user.generate_and_send_multi_factor_email!
        user.reload

        expect(user.multi_factor_email_code).to be_present
        expect(user.multi_factor_email_code).not_to eq(code)
        expect(BCrypt::Password.new(user.multi_factor_email_code)).to eq(code)
      end

      it "sets multi_factor_email_code_sent_at timestamp" do
        Timecop.freeze(Time.current) do
          user.generate_and_send_multi_factor_email!
          user.reload

          expect(user.multi_factor_email_code_sent_at).to be_within(1.second).of(DateTime.current)
        end
      end

      it "sends an email with the OTP code" do
        expect {
          user.generate_and_send_multi_factor_email!
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([user.email])
        expect(mail.subject).to eq("Your multi-factor authentication code")
      end
    end

    describe "#validate_multi_factor_email_code" do
      let(:valid_code) { user.generate_and_send_multi_factor_email! }

      it "returns true for valid OTP code" do
        expect(user.validate_multi_factor_email_code(valid_code)).to be true
      end

      it "returns false for invalid OTP code" do
        valid_code # generate it first
        expect(user.validate_multi_factor_email_code("000000")).to be false
      end

      it "returns false when multi_factor_email_code is blank" do
        user.update_column(:multi_factor_email_code, nil)
        expect(user.validate_multi_factor_email_code("123456")).to be false
      end
    end

    describe "#multi_factor_email_code_expired?" do
      it "returns true when multi_factor_email_code_sent_at is blank" do
        user.update_column(:multi_factor_email_code_sent_at, nil)
        expect(user.multi_factor_email_code_expired?).to be true
      end

      it "returns false when OTP was sent less than 10 minutes ago" do
        user.update_column(:multi_factor_email_code_sent_at, 5.minutes.ago)
        expect(user.multi_factor_email_code_expired?).to be false
      end

      it "returns true when OTP was sent more than 10 minutes ago" do
        user.update_column(:multi_factor_email_code_sent_at, 11.minutes.ago)
        expect(user.multi_factor_email_code_expired?).to be true
      end

      it "returns false at exactly 10 minutes" do
        user.update_column(:multi_factor_email_code_sent_at, 10.minutes.ago)
        expect(user.multi_factor_email_code_expired?).to be false
      end
    end
  end
end
