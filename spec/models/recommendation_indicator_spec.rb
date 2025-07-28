require "rails_helper"

RSpec.describe RecommendationIndicator, type: :model do
  it { is_expected.to belong_to(:recommendation).optional }
  it { is_expected.to belong_to(:indicator).optional }  
  it { is_expected.to validate_presence_of(:recommendation_id) }
  it { is_expected.to validate_presence_of(:indicator_id) }

  context "with an indicator and a recommendation" do
    let(:indicator) { FactoryBot.create(:indicator) }
    let(:recommendation) { FactoryBot.create(:recommendation) }

    let(:whodunnit) { FactoryBot.create(:user).id }
    before { allow(::PaperTrail.request).to receive(:whodunnit).and_return(whodunnit) }

    subject { described_class.create(indicator: indicator, recommendation: recommendation) }

    it "create sets the relationship_updated_at on the indicator" do
      expect { subject }.to change { indicator.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_at on the recommendation" do
      expect { subject }.to change { recommendation.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the indicator" do
      subject
      expect { subject.touch }.to change { indicator.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the recommendation" do
      subject
      expect { subject.touch }.to change { recommendation.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the indicator" do
      expect { subject.destroy }.to change { indicator.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_by_id on the recommendation" do
      expect { subject.destroy }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "create sets the relationship_updated_by_id on the indicator" do
      expect { subject }.to change { indicator.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "create sets the relationship_updated_by_id on the recommendation" do
      expect { subject }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the indicator" do
      subject
      indicator.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { indicator.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the recommendation" do
      subject
      recommendation.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the indicator" do
      expect { subject.destroy }.to change { indicator.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the recommendation" do
      expect { subject.destroy }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end
  end
end
