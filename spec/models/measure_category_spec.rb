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

  context "save_with_cleanup when the measure has:\n" do
    let(:run_test) do
      # This test is complicated so first we'll check that we've set it up correctly

      # Check that the other measure starts with the expected categories
      expect(
        other_measure.reload.categories.map(&:short_title)
      ).to match_array(
        other_measure_categories.map(&:short_title)
      )
      expect(other_measure.reload.categories).to match_array(other_measure_categories)

      # Check that the subject measure starts with the expected categories
      expect(
        measure.reload.categories.map(&:short_title)
      ).to match_array(
        categories_before.map(&:short_title)
      )
      expect(measure.reload.categories).to match_array(categories_before)

      # Create the new category alongside any potential race conditions
      [potential_race_conditions, new_category].flatten.compact.map do |category_to_add|
        described_class.new(category: category_to_add, measure: measure)
      end.map do |measure_category|
        Thread.new do
          measure_category.save_with_cleanup
        rescue ActiveRecord::RecordInvalid => error
          error
        end
      end.each(&:join)

      # The measure should have the new category, either added or by replacing an existing one
      expect(
        measure.categories.reload.map(&:short_title)
      ).to match_array(
        categories_after.map(&:short_title)
      )
      expect(measure.categories.reload).to match_array(categories_after)

      # The other measure should be unaffected by the change
      expect(
        other_measure.categories.reload.map(&:short_title)
      ).to match_array(
        other_measure_categories.map(&:short_title)
      )
      expect(other_measure.categories.reload).to match_array(other_measure_categories)
    end

    let!(:other_measure_categories) do
      [categories_allow, categories_disallow.map(&:first)].flatten.flatten
    end

    let!(:other_measure) do
      FactoryBot.create(
        :measure,
        title: "Control measure to test that adding a category to one measure doesn't affect another"
      ).tap do |measure|
        other_measure_categories.each do |category|
          described_class.create(category: category, measure: measure)
        end
      end
    end

    let(:potential_race_conditions) { nil }

    let(:measure) { FactoryBot.create(:measure) }

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
          described_class.create(category: categories_disallow.first.first, measure: measure)
        end

        let(:categories_before) { [categories_disallow.first.first] }
        let(:new_category) { categories_disallow.first.second }
        let(:categories_after) { [new_category] }
        let(:potential_race_conditions) do
          [
            categories_disallow.first.first,
            categories_disallow.first.third
          ]
        end

        it "replaces the existing category" do
          run_test
        end
      end

      context "from the same taxonomy with allow_multiple: true\n" do
        before do
          described_class.create(category: categories_allow.first.first, measure: measure)
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
          described_class.create(category: categories_disallow.first.first, measure: measure)
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
          described_class.create(category: categories_allow.first.first, measure: measure)
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
          described_class.create(category: categories_allow.first.first, measure: measure)
          described_class.create(category: categories_allow.first.second, measure: measure)
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
          described_class.create(category: categories_allow.first.first, measure: measure)
          described_class.create(category: categories_allow.second.first, measure: measure)
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
          described_class.create(category: categories_disallow.first.first, measure: measure)
        end

        context "and one from a different taxonomy with allow_multiple: true\n" do
          before do
            described_class.create(category: categories_allow.first.first, measure: measure)
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
          let(:potential_race_conditions) do
            [
              categories_disallow.first.first,
              categories_disallow.first.third
            ]
          end

          it "replaces the existing category from its taxonomy" do
            run_test
          end
        end

        context "and one from a different taxonomy with allow_multiple: false\n" do
          before do
            described_class.create(category: categories_disallow.second.first, measure: measure)
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
          let(:potential_race_conditions) do
            [
              categories_disallow.first.first,
              categories_disallow.first.third
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
            described_class.create(category: category, measure: measure)
          end
        end
      end

      context "and one from each of every taxonomy with allow_multiple: false\n" do
        before do
          categories_disallow.each do |taxonomy|
            described_class.create(category: taxonomy.first, measure: measure)
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
          let(:potential_race_conditions) do
            [
              categories_disallow.first.first,
              categories_disallow.first.third
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
            described_class.create(category: taxonomy.first, measure: measure)
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
          let(:potential_race_conditions) do
            [
              categories_disallow.first.first,
              categories_disallow.first.third
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
