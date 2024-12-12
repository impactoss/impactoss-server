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

  describe "indicators" do
    subject { FactoryBot.create(:recommendation) }

    let(:indicator_traits) {
      []
    }

    let(:first_direct_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "First Direct Indicator") }
    let(:second_direct_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "Second Direct Indicator") }

    let(:indicator_via_first_measure) { FactoryBot.create(:indicator, *indicator_traits, title: "Indicator via First Measure") }
    let(:indicator_via_second_measure) { FactoryBot.create(:indicator, *indicator_traits, title: "Indicator via Second Measure") }

    let(:first_shared_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "First Shared Indicator") }
    let(:second_shared_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "Second Shared Indicator") }

    let(:first_measure) { FactoryBot.create(:measure) }
    let(:second_measure) { FactoryBot.create(:measure) }

    let(:all_unique_indicators) {
      [
        first_direct_indicator,
        second_direct_indicator,
        indicator_via_first_measure,
        indicator_via_second_measure,
        first_shared_indicator,
        second_shared_indicator

      ]
    }

    before do
      # Create direct indicators
      FactoryBot.create(:recommendation_indicator, recommendation: subject, indicator: first_direct_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: subject, indicator: second_direct_indicator)

      # Create indicators via measures
      FactoryBot.create(:measure_indicator, measure: first_measure, indicator: indicator_via_first_measure)
      FactoryBot.create(:measure_indicator, measure: second_measure, indicator: indicator_via_second_measure)

      # Associate measures with the recommendation
      FactoryBot.create(:recommendation_measure, recommendation: subject, measure: first_measure)
      FactoryBot.create(:recommendation_measure, recommendation: subject, measure: second_measure)

      # Create shared indicators
      FactoryBot.create(:measure_indicator, measure: first_measure, indicator: first_shared_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: subject, indicator: first_shared_indicator)
      FactoryBot.create(:measure_indicator, measure: second_measure, indicator: second_shared_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: subject, indicator: second_shared_indicator)
    end

    it "contains all distinct indicators from measures and recommendations" do
      expect(subject.indicators.to_a).to match_array(all_unique_indicators)
    end

    describe "indicator_ids" do
      it "contains all distinct indicator ids from measures and recommendations" do
        expect(subject.indicator_ids).not_to be_empty
        expect(subject.indicator_ids).to match_array(all_unique_indicators.map(&:id))
      end
    end

    context "with due_dates" do
      let(:indicator_traits) { [:with_12_due_dates] }

      it "forwards the due_dates from the combined indicators" do
        expect(subject.due_dates.to_a).not_to be_empty
        expect(subject.due_dates.to_a).to match_array(subject.indicators.flat_map(&:due_dates))
      end
    end

    context "with progress reports" do
      before do
        all_unique_indicators.each do |unique_indicator|
          FactoryBot.create(:progress_report, indicator: unique_indicator)
        end
      end

      it "forwards the progress reports from the combined indicators" do
        expect(subject.progress_reports.to_a).not_to be_empty
        expect(subject.progress_reports.to_a).to match_array(subject.indicators.flat_map(&:progress_reports))
      end
    end
  end
end
