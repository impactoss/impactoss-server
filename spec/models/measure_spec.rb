require "rails_helper"

RSpec.describe Measure, type: :model do
  it { is_expected.to validate_presence_of :reference }
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

  context "is_current" do
    let(:measure) { FactoryBot.create(:measure) }
    let(:recommendation) { FactoryBot.create(:recommendation) }

    context "when there are recommendations" do
      before do
        measure.recommendations << recommendation
        allow(recommendation).to receive(:is_current).and_return(is_current)
      end

      context "when a recommendation is current" do
        let(:is_current) { true }

        it "returns true" do
          expect(measure.is_current).to eq(true)
        end
      end

      context "when no recommendation is current" do
        let(:is_current) { false }

        it "returns false" do
          expect(recommendation.is_current).to eq(false)
        end
      end
    end

    context "when there are no recommendations" do
      it "returns true" do
        expect(measure.is_current).to eq(true)
      end
    end
  end
end
