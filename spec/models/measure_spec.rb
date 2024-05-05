require "rails_helper"

RSpec.describe Measure, type: :model do
  it { is_expected.to validate_presence_of :title }

  it "validates uniqueness of reference" do
    FactoryBot.create(:measure, reference: "123")

    expect(FactoryBot.build(:measure, reference: "123")).to be_invalid
    expect(FactoryBot.build(:measure, reference: "456")).to be_valid
  end

  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :categories }
  it { is_expected.to have_many :indicators }
  it { is_expected.to have_many :due_dates }
  it { is_expected.to have_many :progress_reports }
end
