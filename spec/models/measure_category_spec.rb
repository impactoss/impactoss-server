require "rails_helper"
require_relative "../shared_examples/enforce_allow_multiple"

RSpec.describe MeasureCategory, type: :model do
  it { is_expected.to belong_to :measure }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:category_id).scoped_to(:measure_id) }
  it { is_expected.to validate_presence_of :category_id }
  it { is_expected.to validate_presence_of :measure_id }

  context "with default fixtures" do
    let(:category) { FactoryBot.create(:category) }
    let(:measure) { FactoryBot.create(:measure) }
    let(:whodunnit) { FactoryBot.create(:user).id }

    subject { described_class.create(category: category, measure: measure) }

    before { allow(::PaperTrail.request).to receive(:whodunnit).and_return(whodunnit) }

    it "creates a valid record" do
      expect(subject).to be_valid
    end

    it "create sets the relationship_updated_at on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the measure" do
      subject
      expect { subject.touch }.to change { measure.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_by_id on the measure" do
      expect { subject }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the measure" do
      subject
      measure.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the measure" do
      expect { subject.destroy }.to change { measure.reload.relationship_updated_by_id }.to(whodunnit)
    end
  end

  include_examples "save_with_cleanup enforces taxonomy.allow_multiple", {
    association: :measure,
    factory: :measure,
    name: "Measure",
    title: :title
  }
end
