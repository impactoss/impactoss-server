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

  context "adding a category when the user has:\n" do
    let(:run_test) do
      # This test is complicated so first we'll verify the setup

      # Check that the other user starts with the expected categories
      expect(
        other_user.reload.categories.map(&:short_title)
      ).to match_array(
        other_user_categories.map(&:short_title)
      )
      expect(other_user.reload.categories).to match_array(other_user_categories)

      # Check that the subject user starts with the expected categories
      expect(
        user.reload.categories.map(&:short_title)
      ).to match_array(
        categories_before.map(&:short_title)
      )
      expect(user.reload.categories).to match_array(categories_before)

      # Create the new category
      described_class.create(category: new_category, user: user)

      # The user should have the new category, either added or by replacing an existing one
      expect(
        user.categories.reload.map(&:short_title)
      ).to match_array(
        categories_after.map(&:short_title)
      )
      expect(user.categories.reload).to match_array(categories_after)

      # The other user should be unaffected by the change
      expect(
        other_user.categories.reload.map(&:short_title)
      ).to match_array(
        other_user_categories.map(&:short_title)
      )
      expect(other_user.categories.reload).to match_array(other_user_categories)
    end

    let!(:other_user_categories) do
      [categories_allow, categories_disallow.map(&:first)].flatten.flatten
    end

    let!(:other_user) do
      FactoryBot.create(
        :user,
        name: "Control user to test that adding a category to one user doesn't affect another"
      ).tap do |user|
        other_user_categories.each do |category|
          described_class.create(category: category, user: user)
        end
      end
    end

    let(:user) { FactoryBot.create(:user) }

    let!(:taxonomies_allow) do
      3.times.map do |index|
        FactoryBot.create(:taxonomy, allow_multiple: true, title: "Taxonomy: Allow Multiple, #{index + 1}")
      end
    end
    let!(:taxonomies_disallow) do
      3.times.map do |index|
        FactoryBot.create(:taxonomy, allow_multiple: false, title: "Taxonomy: Disallow Multiple, #{index + 1}")
      end
    end

    let!(:categories_allow) do
      taxonomies_allow.map.with_index do |taxonomy, taxonomy_index|
        3.times.map do |category_index|
          FactoryBot.create(
            :category,
            taxonomy: taxonomy,
            short_title: "Taxonomy Allow #{taxonomy_index + 1} - Category #{category_index + 1}",
            title: "Category #{category_index + 1} for Taxonomy Allow #{taxonomy_index + 1}"
          )
        end
      end
    end
    let!(:categories_disallow) do
      taxonomies_disallow.map.with_index do |taxonomy, taxonomy_index|
        3.times.map do |category_index|
          FactoryBot.create(
            :category,
            taxonomy: taxonomy,
            short_title: "Taxonomy Allow #{taxonomy_index + 1} - Category #{category_index + 1}",
            title: "Category #{category_index + 1} for Taxonomy Allow #{taxonomy_index + 1}"
          )
        end
      end
    end

    context "no categories\n" do
      let(:categories_before) { [] }
      let(:new_category) { categories_allow.first.first }
      let(:categories_after) { [new_category] }

      it "adds the new category without replacement" do
        run_test
      end
    end

    context "one existing category\n" do
      context "from the same taxonomy with allow_multiple: false\n" do
        before do
          described_class.create(category: categories_disallow.first.first, user: user)
        end

        let(:categories_before) { [categories_disallow.first.first] }
        let(:new_category) { categories_disallow.first.second }
        let(:categories_after) { [new_category] }

        it "replaces the existing category" do
          run_test
        end
      end

      context "from the same taxonomy with allow_multiple: true\n" do
        before do
          described_class.create(category: categories_allow.first.first, user: user)
        end

        let(:categories_before) { [categories_allow.first.first] }
        let(:new_category) { categories_allow.first.second }
        let(:categories_after) do
          [
            categories_allow.first.first,
            new_category # added without replacement
          ]
        end

        it "adds the new category without replacement" do
          run_test
        end
      end

      context "from a different taxonomy with allow_multiple: false\n" do
        before do
          described_class.create(category: categories_disallow.first.first, user: user)
        end

        let(:categories_before) { [categories_disallow.first.first] }
        let(:new_category) { categories_disallow.second.first }
        let(:categories_after) do
          [
            categories_disallow.first.first,
            new_category # added without replacement
          ]
        end

        it "adds the new category without replacement" do
          run_test
        end
      end

      context "from a different taxonomy with allow_multiple: true\n" do
        before do
          described_class.create(category: categories_allow.first.first, user: user)
        end

        let(:categories_before) { [categories_allow.first.first] }
        let(:new_category) { categories_allow.second.first }
        let(:categories_after) do
          [
            categories_allow.first.first,
            new_category # added without replacement
          ]
        end

        it "adds the new category without replacement" do
          run_test
        end
      end
    end

    context "two existing categories\n" do
      context "from the same taxonomy with allow_multiple: true\n" do
        before do
          described_class.create(category: categories_allow.first.first, user: user)
          described_class.create(category: categories_allow.first.second, user: user)
        end

        let(:categories_before) do
          [
            categories_allow.first.first,
            categories_allow.first.second
          ]
        end
        let(:new_category) { categories_allow.first.third }
        let(:categories_after) do
          [
            categories_allow.first.first,
            categories_allow.first.second,
            new_category # added without replacement
          ]
        end

        it "adds the new category without replacement" do
          run_test
        end
      end

      context "from two different taxonomies with allow_multiple: true\n" do
        before do
          described_class.create(category: categories_allow.first.first, user: user)
          described_class.create(category: categories_allow.second.first, user: user)
        end

        let(:categories_before) do
          [
            categories_allow.first.first,
            categories_allow.second.first
          ]
        end
        let(:new_category) { categories_allow.third.first }
        let(:categories_after) do
          [
            categories_allow.first.first,
            categories_allow.second.first,
            new_category # added without replacement
          ]
        end

        it "adds the new category without replacement" do
          run_test
        end
      end

      context "one from the same taxonomy with allow_multiple: false\n" do
        before do
          described_class.create(category: categories_disallow.first.first, user: user)
        end

        context "and one from a different taxonomy with allow_multiple: true\n" do
          before do
            described_class.create(category: categories_allow.first.first, user: user)
          end

          let(:categories_before) do
            [
              categories_allow.first.first,
              categories_disallow.first.first
            ]
          end
          let(:new_category) { categories_disallow.first.second }
          let(:categories_after) do
            [
              categories_allow.first.first,
              new_category # replaced categories_disallow.first.first
            ]
          end

          it "replaces the existing category from its taxonomy" do
            run_test
          end
        end

        context "and one from a different taxonomy with allow_multiple: false\n" do
          before do
            described_class.create(category: categories_disallow.second.first, user: user)
          end

          let(:categories_before) do
            [
              categories_disallow.first.first,
              categories_disallow.second.first
            ]
          end
          let(:new_category) { categories_disallow.first.second }
          let(:categories_after) do
            [
              new_category, # replaced categories_disallow.first.first
              categories_disallow.second.first
            ]
          end

          it "replaces the existing category from its taxonomy" do
            run_test
          end
        end
      end
    end

    context "two existing categories from the first two taxonomies with allow_multiple: true\n" do
      before do
        categories_allow.first(2).each do |taxonomy|
          taxonomy.first(2).each do |category|
            described_class.create(category: category, user: user)
          end
        end
      end

      context "and one from each of every taxonomy with allow_multiple: false\n" do
        before do
          categories_disallow.each do |taxonomy|
            described_class.create(category: taxonomy.first, user: user)
          end
        end

        let(:categories_before) do
          [
            categories_allow.first.first,
            categories_allow.first.second,
            categories_allow.second.first,
            categories_allow.second.second,
            categories_disallow.first.first,
            categories_disallow.second.first,
            categories_disallow.third.first
          ]
        end

        context "and the new category is from a taxonomy with allow_multiple: true\n" do
          let(:new_category) { categories_allow.third.first }
          let(:categories_after) do
            [
              categories_allow.first.first,
              categories_allow.first.second,
              categories_allow.second.first,
              categories_allow.second.second,
              new_category, # added without replacement
              categories_disallow.first.first,
              categories_disallow.second.first,
              categories_disallow.third.first
            ]
          end

          it "adds the new category without replacement" do
            run_test
          end
        end

        context "and the new category is from a taxonomy with allow_multiple: false\n" do
          let(:new_category) { categories_disallow.first.second }
          let(:categories_after) do
            [
              categories_allow.first.first,
              categories_allow.first.second,
              categories_allow.second.first,
              categories_allow.second.second,
              new_category, # replaced categories_disallow.first.first
              categories_disallow.second.first,
              categories_disallow.third.first
            ]
          end

          it "replaces the existing category from its taxonomy" do
            run_test
          end
        end
      end

      context "and one from each of two taxonomies with allow_multiple: false\n" do
        before do
          categories_disallow.first(2).each do |taxonomy|
            described_class.create(category: taxonomy.first, user: user)
          end
        end

        let(:categories_before) do
          [
            categories_allow.first.first,
            categories_allow.first.second,
            categories_allow.second.first,
            categories_allow.second.second,
            categories_disallow.first.first,
            categories_disallow.second.first
          ]
        end

        context "and the new category is from the other taxonomy with allow_multiple: false\n" do
          let(:new_category) { categories_disallow.third.first }
          let(:categories_after) do
            [
              categories_allow.first.first,
              categories_allow.first.second,
              categories_allow.second.first,
              categories_allow.second.second,
              categories_disallow.first.first,
              categories_disallow.second.first,
              new_category # added without replacement
            ]
          end

          it "adds the new category without replacement" do
            run_test
          end
        end

        context "and the new category is from one of those two taxonomies with allow_multiple: false\n" do
          let(:new_category) { categories_disallow.first.second }
          let(:categories_after) do
            [
              categories_allow.first.first,
              categories_allow.first.second,
              categories_allow.second.first,
              categories_allow.second.second,
              new_category, # replaced categories_disallow.first.first
              categories_disallow.second.first
            ]
          end

          it "replaces the existing category from its taxonomy" do
            run_test
          end
        end

        context "and the new category is an additional one from a taxonomy with allow_multiple: true\n" do
          let(:new_category) { categories_allow.first.third }
          let(:categories_after) do
            [
              categories_allow.first.first,
              categories_allow.first.second,
              new_category, # added without replacement
              categories_allow.second.first,
              categories_allow.second.second,
              categories_disallow.first.first,
              categories_disallow.second.first
            ]
          end

          it "adds the new category without replacement" do
            run_test
          end
        end

        context "and the new category is from the other taxonomy with allow_multiple: true\n" do
          let(:new_category) { categories_allow.third.first }
          let(:categories_after) do
            [
              categories_allow.first.first,
              categories_allow.first.second,
              categories_allow.second.first,
              categories_allow.second.second,
              categories_disallow.first.first,
              categories_disallow.second.first,
              new_category # added without replacement
            ]
          end

          it "adds the new category without replacement" do
            run_test
          end
        end
      end
    end
  end
end
