require "rails_helper"

RSpec.describe UserCategory, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :category }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:category_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:category_id) }

  context "with a user and a category" do
    let(:user) { FactoryBot.create(:user) }
    let(:category) { FactoryBot.create(:category) }

    let(:whodunnit) { FactoryBot.create(:user).id }
    before { allow(::PaperTrail.request).to receive(:whodunnit).and_return(whodunnit) }

    subject { described_class.create(user: user, category: category) }

    it "create sets the relationship_updated_at on the user" do
      expect { subject }.to change { user.reload.relationship_updated_at }
    end

    it "update sets the relationship_updated_at on the user" do
      subject
      expect { subject.touch }.to change { user.reload.relationship_updated_at }
    end

    it "destroy sets the relationship_updated_at on the user" do
      expect { subject.destroy }.to change { user.reload.relationship_updated_at }
    end

    it "create sets the relationship_updated_by_id on the user" do
      expect { subject }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "update sets the relationship_updated_by_id on the user" do
      subject
      user.update_column(:relationship_updated_by_id, nil)
      expect { subject.touch }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end

    it "destroy sets the relationship_updated_by_id on the user" do
      expect { subject.destroy }.to change { user.reload.relationship_updated_by_id }.to(whodunnit)
    end
  end

  context "category.taxonomy.allow_multiple" do
    let(:user) { FactoryBot.create(:user) }

    let(:taxonomy_allow) { FactoryBot.create(:taxonomy, allow_multiple: true, title: "Taxonomy: Allow Multiple") }
    let(:taxonomy_disallow) { FactoryBot.create(:taxonomy, allow_multiple: false, title: "Taxonomy: Disallow Multiple") }

    let(:category_allow_one) { FactoryBot.create(:category, taxonomy: taxonomy_allow, short_title: "Category Allow 1", title: "Category: Allow Multiple, 1") }
    let(:category_allow_two) { FactoryBot.create(:category, taxonomy: taxonomy_allow, short_title: "Category Allow 2", title: "Category: Allow Multiple, 2") }

    let(:category_disallow_one) { FactoryBot.create(:category, taxonomy: taxonomy_disallow, short_title: "Category Disallow 1", title: "Category: Disallow Multiple, 1") }
    let(:category_disallow_two) { FactoryBot.create(:category, taxonomy: taxonomy_disallow, short_title: "Category Disallow 2", title: "Category: Disallow Multiple, 2") }

    context "when user already has a category with taxonomy.allow_multiple: false" do
      before do
        described_class.create(category: category_disallow_one, user: user)
      end

      it "adding a second category with { allow_multiple: false } replaces the existing category" do
        expect(user.reload.categories).to match_array([category_disallow_one])

        described_class.create(category: category_disallow_two, user: user)

        expect(user.reload.categories).to match_array([category_disallow_two])
      end

      it "adding a second category with { allow_multiple: true } replaces the existing category" do
        expect(user.reload.categories).to match_array([category_disallow_one])

        described_class.create(category: category_allow_two, user: user)

        expect(user.reload.categories).to match_array([category_allow_two])
      end
    end

    context "when user already has a category with taxonomy.allow_multiple: true" do
      before do
        described_class.create(category: category_allow_one, user: user)
      end

      it "adding a second category with { allow_multiple: false } replaces the existing category" do
        expect(user.reload.categories).to match_array([category_allow_one])

        described_class.create(category: category_disallow_two, user: user)

        expect(user.reload.categories).to match_array([category_disallow_two])
      end

      it "adding a second category with { allow_multiple: true } results in both categories" do
        expect(user.reload.categories).to match_array([category_allow_one])

        described_class.create(category: category_allow_two, user: user)

        expect(user.reload.categories).to match_array([category_allow_one, category_allow_two])
      end
    end
  end
end
