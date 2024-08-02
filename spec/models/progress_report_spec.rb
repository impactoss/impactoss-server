require "rails_helper"

RSpec.describe ProgressReport, type: :model do
  it { is_expected.to belong_to :indicator }
  it { is_expected.to belong_to(:due_date).optional }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to have_many :measures }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :categories }
  it { is_expected.to have_one :manager }
  it { is_expected.to validate_presence_of(:indicator_id) }

  describe "#send_updated_emails" do
    let(:categories) { FactoryBot.create_list(:category, 5) }
    let(:child_categories) do
      categories.map { |parent|
        FactoryBot.create(:category,
          parent_id: parent.id,
          taxonomy: FactoryBot.create(:taxonomy, taxonomy: parent.taxonomy))
      }
    end
    let(:manager_category) { FactoryBot.create(:category, manager:) }
    let(:measure) { FactoryBot.create(:measure) }
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:guest) { FactoryBot.create(:user) }
    let(:manager) { FactoryBot.create(:user, :manager) }
    let(:contributor) { FactoryBot.create(:user, :contributor) }
    let(:contributor_indicator) { FactoryBot.create(:indicator, manager: contributor) }

    before do
      allow(::PaperTrail.request).to receive(:whodunnit).and_return(manager.id)

      measure.indicators << contributor_indicator
      recommendation.measures << measure
      recommendation.categories += child_categories
      recommendation.categories << manager_category
    end

    subject do
      FactoryBot.create(:progress_report, indicator: contributor_indicator)
    end

    it "only sends updated emails to categories where the manager didn't make the change" do
      expect(ProgressReportMailer).not_to receive(:updated).with(subject, manager_category)
      child_categories.each do |category|
        expect(ProgressReportMailer).to receive(:updated).with(subject, category).and_return(double(deliver_now: true))
      end
      categories.each do |category|
        expect(ProgressReportMailer).to receive(:updated).with(subject, category).and_return(double(deliver_now: true))
      end

      subject.send_updated_emails
    end
  end

  context "is_current" do
    let(:indicator) { FactoryBot.create(:indicator) }
    let(:progress_report) { FactoryBot.create(:progress_report, indicator:) }

    it "is false when indicator.is_current = false" do
      allow(indicator).to receive(:is_current).and_return(false)

      expect(progress_report.is_current).to eq(false)
    end

    it "is true when indicator.is_current = true" do
      allow(indicator).to receive(:is_current).and_return(true)

      expect(progress_report.is_current).to eq(true)
    end
  end
end
