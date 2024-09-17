require "rails_helper"

RSpec.describe RecommendationCategory, type: :model do
  it { is_expected.to belong_to :recommendation }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:category_id).scoped_to(:recommendation_id) }
  it { is_expected.to validate_presence_of(:recommendation_id) }
  it { is_expected.to validate_presence_of(:category_id) }

  context "with default fixtures" do
    let(:category) { FactoryBot.create(:category) }
    let(:recommendation) { FactoryBot.create(:recommendation) }
    let(:whodunnit) { FactoryBot.create(:user).id }

    subject { described_class.create(category: category, recommendation: recommendation) }

    before { allow(::PaperTrail.request).to receive(:whodunnit).and_return(whodunnit) }

    it "creates a valid record" do
      expect(subject).to be_valid
    end

    it "create sets the relationship_updated_at on the recommendation" do
      expect { subject }.to change { recommendation.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the recommendation" do
      subject
      expect { subject.touch }.to change { recommendation.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the recommendation" do
      expect { subject.destroy }.to change { recommendation.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_by_id on the recommendation" do
      expect { subject }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the recommendation" do
      subject
      recommendation.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the recommendation" do
      expect { subject.destroy }.to change { recommendation.reload.relationship_updated_by_id }.to(whodunnit)
    end
  end

  context "category.taxonomy.allow_multiple" do
    let(:recommendation) { FactoryBot.create(:recommendation) }

    let(:taxonomy_allow) { FactoryBot.create(:taxonomy, allow_multiple: true, title: "Taxonomy: Allow Multiple") }
    let(:taxonomy_disallow) { FactoryBot.create(:taxonomy, allow_multiple: false, title: "Taxonomy: Disallow Multiple") }

    let(:category_allow_one) { FactoryBot.create(:category, taxonomy: taxonomy_allow, short_title: "Category Allow 1", title: "Category: Allow Multiple, 1") }
    let(:category_allow_two) { FactoryBot.create(:category, taxonomy: taxonomy_allow, short_title: "Category Allow 2", title: "Category: Allow Multiple, 2") }

    let(:category_disallow_one) { FactoryBot.create(:category, taxonomy: taxonomy_disallow, short_title: "Category Disallow 1", title: "Category: Disallow Multiple, 1") }
    let(:category_disallow_two) { FactoryBot.create(:category, taxonomy: taxonomy_disallow, short_title: "Category Disallow 2", title: "Category: Disallow Multiple, 2") }

    context "when recommendation already has a category with taxonomy.allow_multiple: false" do
      before do
        described_class.create(category: category_disallow_one, recommendation: recommendation)
      end

      it "adding a second category with { allow_multiple: false } replaces the existing category" do
        expect(recommendation.reload.categories).to match_array([category_disallow_one])

        described_class.create(category: category_disallow_two, recommendation: recommendation)

        expect(recommendation.reload.categories).to match_array([category_disallow_two])
      end

      it "adding a second category with { allow_multiple: true } replaces the existing category" do
        expect(recommendation.reload.categories).to match_array([category_disallow_one])

        described_class.create(category: category_allow_two, recommendation: recommendation)

        expect(recommendation.reload.categories).to match_array([category_allow_two])
      end
    end

    context "when recommendation already has a category with taxonomy.allow_multiple: true" do
      before do
        described_class.create(category: category_allow_one, recommendation: recommendation)
      end

      it "adding a second category with { allow_multiple: false } replaces the existing category" do
        expect(recommendation.reload.categories).to match_array([category_allow_one])

        described_class.create(category: category_disallow_two, recommendation: recommendation)

        expect(recommendation.reload.categories).to match_array([category_disallow_two])
      end

      it "adding a second category with { allow_multiple: true } results in both categories" do
        expect(recommendation.reload.categories).to match_array([category_allow_one])

        described_class.create(category: category_allow_two, recommendation: recommendation)

        expect(recommendation.reload.categories).to match_array([category_allow_one, category_allow_two])
      end
    end
  end
end
