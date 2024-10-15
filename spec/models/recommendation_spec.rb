# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recommendation, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :reference }

  it "validates uniqueness of reference" do
    FactoryBot.create(:recommendation, reference: "123")

    expect(FactoryBot.build(:recommendation, reference: "123")).to be_invalid
    expect(FactoryBot.build(:recommendation, reference: "456")).to be_valid
  end

  it { is_expected.to have_many :categories }
  it { is_expected.to have_many :measures }
  it { is_expected.to have_many :indicators }
  it { is_expected.to have_many :progress_reports }
  it { is_expected.to have_many :due_dates }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :recommendation_recommendations }
  it { is_expected.to have_many :recommendation_categories }
  it { is_expected.to have_many :recommendation_measures }
  it { is_expected.to have_many :recommendation_indicators }

  it { is_expected.to belong_to(:framework).optional }

  it { is_expected.to accept_nested_attributes_for :recommendation_categories }

  context "is_current" do
    let(:category) { FactoryBot.create(:category) }
    let(:recommendation) { FactoryBot.create(:recommendation) }

    before do
      recommendation.categories << category

      allow(category)
        .to(receive(:has_reporting_cycle_taxonomy?))
        .and_return(has_reporting_cycle_taxonomy)
    end

    context "when it has a category that is linked to a reporting cycle" do
      let(:has_reporting_cycle_taxonomy) { true }

      context "when no category is current" do
        it "returns false" do
          expect(recommendation.is_current).to eq(false)
        end
      end

      context "when it has a category that is current" do
        it "returns true" do
          allow(category).to receive(:is_current).and_return(true)

          expect(recommendation.is_current).to eq(true)
        end
      end
    end

    context "when it has a category that is not linked to a reporting cycle" do
      let(:has_reporting_cycle_taxonomy) { false }

      it "returns true" do
        expect(recommendation.is_current).to eq(true)
      end

      it "returns true even if no category is current" do
        allow(category).to receive(:is_current).and_return(false)

        expect(recommendation.is_current).to eq(true)
      end
    end
  end
end
