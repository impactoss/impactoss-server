require "rails_helper"

RSpec.describe MeasureCategory, type: :model do
  it { is_expected.to belong_to :measure }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:category_id).scoped_to(:measure_id) }
  it { is_expected.to validate_presence_of :category_id }
  it { is_expected.to validate_presence_of :measure_id }

  let(:category) { FactoryBot.create(:category) }
  let(:measure) { FactoryBot.create(:measure) }

  subject { described_class.create(category: category, measure: measure) }

  it "works" do
    expect(subject).to be_valid
  end

  it "create sets the relationship_updated_at on the measure" do
    expect { subject }.to change { measure.reload.relationship_updated_at }
  end

  let(:whodunnit) { FactoryBot.create(:user).id }
  before { allow(::PaperTrail.request).to receive(:whodunnit).and_return(whodunnit) }

  subject { described_class.create(category: category, measure: measure) }

  it "works" do
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
