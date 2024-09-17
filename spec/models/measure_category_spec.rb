require "rails_helper"

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

  context "category.taxonomy.allow_multiple" do
    let(:measure) { FactoryBot.create(:measure) }

    let(:taxonomy_allow) { FactoryBot.create(:taxonomy, allow_multiple: true, title: "Taxonomy: Allow Multiple") }
    let(:taxonomy_disallow) { FactoryBot.create(:taxonomy, allow_multiple: false, title: "Taxonomy: Disallow Multiple") }

    let(:category_allow_one) { FactoryBot.create(:category, taxonomy: taxonomy_allow, short_title: "Category Allow 1", title: "Category: Allow Multiple, 1") }
    let(:category_allow_two) { FactoryBot.create(:category, taxonomy: taxonomy_allow, short_title: "Category Allow 2", title: "Category: Allow Multiple, 2") }

    let(:category_disallow_one) { FactoryBot.create(:category, taxonomy: taxonomy_disallow, short_title: "Category Disallow 1", title: "Category: Disallow Multiple, 1") }
    let(:category_disallow_two) { FactoryBot.create(:category, taxonomy: taxonomy_disallow, short_title: "Category Disallow 2", title: "Category: Disallow Multiple, 2") }

    context "when measure already has a category with taxonomy.allow_multiple: false" do
      before do
        described_class.create(category: category_disallow_one, measure: measure)
      end

      it "adding a second category with { allow_multiple: false } replaces the existing category" do
        expect(measure.reload.categories).to match_array([category_disallow_one])

        described_class.create(category: category_disallow_two, measure: measure)

        expect(measure.reload.categories).to match_array([category_disallow_two])
      end

      it "adding a second category with { allow_multiple: true } replaces the existing category" do
        expect(measure.reload.categories).to match_array([category_disallow_one])

        described_class.create(category: category_allow_two, measure: measure)

        expect(measure.reload.categories).to match_array([category_allow_two])
      end
    end

    context "when measure already has a category with taxonomy.allow_multiple: true" do
      before do
        described_class.create(category: category_allow_one, measure: measure)
      end

      it "adding a second category with { allow_multiple: false } replaces the existing category" do
        expect(measure.reload.categories).to match_array([category_allow_one])

        described_class.create(category: category_disallow_two, measure: measure)

        expect(measure.reload.categories).to match_array([category_disallow_two])
      end

      it "adding a second category with { allow_multiple: true } results in both categories" do
        expect(measure.reload.categories).to match_array([category_allow_one])

        described_class.create(category: category_allow_two, measure: measure)

        expect(measure.reload.categories).to match_array([category_allow_one, category_allow_two])
      end
    end
  end
end
