require "rails_helper"

RSpec.describe MeasureIndicator, type: :model do
  it { is_expected.to belong_to :measure }
  it { is_expected.to belong_to :indicator }
  it { is_expected.to validate_uniqueness_of(:measure_id).scoped_to(:indicator_id) }
  it { is_expected.to validate_presence_of(:measure_id) }
  it { is_expected.to validate_presence_of(:indicator_id) }

  context "with an indicator and a measure" do
    let(:indicator) { FactoryBot.create(:indicator) }
    let(:measure) { FactoryBot.create(:measure) }

    subject { described_class.create(indicator: indicator, measure: measure) }

    it "create sets the relationship_updated_at on the indicator" do
      expect { subject }.to change { indicator.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_at on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the indicator" do
      subject
      expect { subject.touch }.to change { indicator.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the measure" do
      subject
      expect { subject.touch }.to change { measure.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the indicator" do
      expect { subject.destroy }.to change { indicator.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_at }
    end
  end
end
