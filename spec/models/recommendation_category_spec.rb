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

  context "adding a category when the recommendation has:\n" do
    let(:run_test) do
      # This test is complicated so first we'll verify the setup

      # Check that the other recommendation starts with the expected categories
      expect(
        other_recommendation.reload.categories.map(&:short_title)
      ).to match_array(
        other_recommendation_categories.map(&:short_title)
      )
      expect(other_recommendation.reload.categories).to match_array(other_recommendation_categories)

      # Check that the subject recommendation starts with the expected categories
      expect(
        recommendation.reload.categories.map(&:short_title)
      ).to match_array(
        categories_before.map(&:short_title)
      )
      expect(recommendation.reload.categories).to match_array(categories_before)

      # Create the new category
      described_class.create(category: new_category, recommendation: recommendation)

      # The recommendation should have the new category, either added or by replacing an existing one
      expect(
        recommendation.categories.reload.map(&:short_title)
      ).to match_array(
        categories_after.map(&:short_title)
      )
      expect(recommendation.categories.reload).to match_array(categories_after)

      # The other recommendation should be unaffected by the change
      expect(
        other_recommendation.categories.reload.map(&:short_title)
      ).to match_array(
        other_recommendation_categories.map(&:short_title)
      )
      expect(other_recommendation.categories.reload).to match_array(other_recommendation_categories)
    end

    let!(:other_recommendation_categories) do
      [categories_allow, categories_disallow.map(&:first)].flatten.flatten
    end

    let!(:other_recommendation) do
      FactoryBot.create(
        :recommendation,
        title: "Control recommendation to test that adding a category to one recommendation doesn't affect another"
      ).tap do |recommendation|
        other_recommendation_categories.each do |category|
          described_class.create(category: category, recommendation: recommendation)
        end
      end
    end

    let(:recommendation) { FactoryBot.create(:recommendation) }

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
          described_class.create(category: categories_disallow.first.first, recommendation: recommendation)
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
          described_class.create(category: categories_allow.first.first, recommendation: recommendation)
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
          described_class.create(category: categories_disallow.first.first, recommendation: recommendation)
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
          described_class.create(category: categories_allow.first.first, recommendation: recommendation)
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
          described_class.create(category: categories_allow.first.first, recommendation: recommendation)
          described_class.create(category: categories_allow.first.second, recommendation: recommendation)
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
          described_class.create(category: categories_allow.first.first, recommendation: recommendation)
          described_class.create(category: categories_allow.second.first, recommendation: recommendation)
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
          described_class.create(category: categories_disallow.first.first, recommendation: recommendation)
        end

        context "and one from a different taxonomy with allow_multiple: true\n" do
          before do
            described_class.create(category: categories_allow.first.first, recommendation: recommendation)
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
            described_class.create(category: categories_disallow.second.first, recommendation: recommendation)
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
            described_class.create(category: category, recommendation: recommendation)
          end
        end
      end

      context "and one from each of every taxonomy with allow_multiple: false\n" do
        before do
          categories_disallow.each do |taxonomy|
            described_class.create(category: taxonomy.first, recommendation: recommendation)
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
            described_class.create(category: taxonomy.first, recommendation: recommendation)
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
