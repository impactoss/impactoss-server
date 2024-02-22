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

  context "when the name has a comma" do
    subject { FactoryBot.create(:user, name: "User, Testing Person") }

    it "shows the name in first_name last_name format" do
      expect(subject.name).to eq("Testing Person User")
    end
  end

  context "when the name has no comma" do
    subject { FactoryBot.create(:user, name: "User Testing Person") }

    it "shows the name in the original format" do
      expect(subject.name).to eq("User Testing Person")
    end
  end
end
