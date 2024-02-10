require "rails_helper"

RSpec.describe RecommendationMeasure, type: :model do
  it { is_expected.to belong_to :recommendation }
  it { is_expected.to belong_to :measure }
  it { is_expected.to validate_uniqueness_of(:measure_id).scoped_to(:recommendation_id) }
  it { is_expected.to validate_presence_of(:recommendation_id) }
  it { is_expected.to validate_presence_of(:measure_id) }

  context "with a recommendation and a measure" do
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:measure) { FactoryBot.create(:measure) }

    let(:whodunnit) { FactoryBot.create(:user).id }
    before { allow(::PaperTrail.request).to receive(:whodunnit).and_return(whodunnit) }

    subject { described_class.create(recommendation: recommendation, measure: measure) }

    it "create sets the relationship_updated_at on the recommendation" do
      expect { subject }.to change { recommendation.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_at on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the recommendation" do
      subject
      expect { subject.touch }.to change { recommendation.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the measure" do
      subject
      expect { subject.touch }.to change { measure.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the recommendation" do
      expect { subject.destroy }.to change { recommendation.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_by_id on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "create sets the relationship_updated_by_id on the recommendation" do
      expect { subject }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "create sets the relationship_updated_by_id on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the recommendation" do
      subject
      recommendation.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the measure" do
      subject
      measure.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the recommendation" do
      expect { subject.destroy }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end
  end
end
