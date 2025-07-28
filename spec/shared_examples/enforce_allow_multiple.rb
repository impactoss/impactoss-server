# associated_model should be a hash with the following fields:
# - association (symbol): The field that connects the subject model to the associated model
# - factory (symbol): The factory to use to create the connected model
# - name (string): Used to describe the associated model in test descriptions
# - title (symbol): A field that we can use to add a description for clearer test data
# eg:
# associated_model = {
#   association: :recommendation,
#   factory: :recommendation,
#   name: "Recommendation",
#   title: :title
# }

RSpec.shared_examples "save_with_cleanup enforces taxonomy.allow_multiple" do |associated_model|
  describe "#save_with_cleanup" do
    context "adding a category when the #{associated_model[:name]} has:" do
      let(:run_test) do
        # Check that the control association starts with the expected categories
        expect(
          control_association.reload.categories.map(&:short_title)
        ).to match_array(
          control_association_categories.map(&:short_title)
        )
        expect(control_association.reload.categories).to match_array(control_association_categories)

        # Check that the subject association starts with the expected categories
        expect(
          subject_association.reload.categories.map(&:short_title)
        ).to match_array(
          categories_before.map(&:short_title)
        )
        expect(subject_association.reload.categories).to match_array(categories_before)

        # Create the new category alongside any potential race conditions
        [potential_race_conditions, new_category].flatten.compact.map do |category_to_add|
          described_class.new(:category => category_to_add, associated_model[:association] => subject_association)
        end.map do |new_category|
          Thread.new do
            new_category.save_with_cleanup
          rescue ActiveRecord::RecordInvalid => error
            error
          end
        end.each(&:join)

        # The subject association should have the new category, either added or by replacing an existing one
        expect(
          subject_association.categories.reload.map(&:short_title)
        ).to match_array(
          categories_after.map(&:short_title)
        )
        expect(subject_association.categories.reload).to match_array(categories_after)

        # The control association should be unaffected by the change
        expect(
          control_association.categories.reload.map(&:short_title)
        ).to match_array(
          control_association_categories.map(&:short_title)
        )
        expect(control_association.categories.reload).to match_array(control_association_categories)
      end

      let!(:subject_association) do
        FactoryBot.create(associated_model[:factory], associated_model[:title] => "Subject association")
      end

      let!(:control_association_categories) do
        [categories_allow, categories_disallow.map(&:first)].flatten.flatten
      end

      let!(:control_association) do
        FactoryBot.create(
          associated_model[:factory],
          associated_model[:title] => "Control association to test that adding a category to the subject doesn't affect a different one"
        ).tap do |created_association|
          control_association_categories.each do |category|
            described_class.create(:category => category, associated_model[:association] => created_association)
          end
        end
      end

      let(:potential_race_conditions) { nil }

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
              short_title: "Taxonomy Disallow #{taxonomy_index + 1} - Category #{category_index + 1}",
              title: "Category #{category_index + 1} for Taxonomy Disallow #{taxonomy_index + 1}"
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
            described_class.create(:category => categories_disallow.first.first, associated_model[:association] => subject_association)
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
            described_class.create(:category => categories_allow.first.first, associated_model[:association] => subject_association)
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
            described_class.create(:category => categories_disallow.first.first, associated_model[:association] => subject_association)
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
            described_class.create(:category => categories_allow.first.first, associated_model[:association] => subject_association)
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
            described_class.create(:category => categories_allow.first.first, associated_model[:association] => subject_association)
            described_class.create(:category => categories_allow.first.second, associated_model[:association] => subject_association)
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
            described_class.create(:category => categories_allow.first.first, associated_model[:association] => subject_association)
            described_class.create(:category => categories_allow.second.first, associated_model[:association] => subject_association)
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

        context "one from a taxonomy with allow_multiple: false\n" do
          before do
            described_class.create(:category => categories_disallow.first.first, associated_model[:association] => subject_association)
          end

          context "and one from a different taxonomy with allow_multiple: true\n" do
            before do
              described_class.create(:category => categories_allow.first.first, associated_model[:association] => subject_association)
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
            # let(:potential_race_conditions) do
            #   [
            #     categories_disallow.first.first,
            #     categories_disallow.first.third
            #   ]
            # end

            it "replaces the existing category from its taxonomy" do
              run_test
            end
          end

          context "and one from a different taxonomy with allow_multiple: false\n" do
            before do
              described_class.create(:category => categories_disallow.second.first, associated_model[:association] => subject_association)
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
            # let(:potential_race_conditions) do
            #   [
            #     categories_disallow.first.first,
            #     categories_disallow.first.third
            #   ]
            # end

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
              described_class.create(:category => category, associated_model[:association] => subject_association)
            end
          end
        end

        context "and one from each of every taxonomy with allow_multiple: false\n" do
          before do
            categories_disallow.each do |taxonomy|
              described_class.create(:category => taxonomy.first, associated_model[:association] => subject_association)
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
            # let(:potential_race_conditions) do
            #   [
            #     categories_disallow.first.first,
            #     categories_disallow.first.third
            #   ]
            # end

            it "replaces the existing category from its taxonomy" do
              run_test
            end
          end
        end

        context "and one from each of two taxonomies with allow_multiple: false\n" do
          before do
            categories_disallow.first(2).each do |taxonomy|
              described_class.create(:category => taxonomy.first, associated_model[:association] => subject_association)
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
            # let(:potential_race_conditions) do
            #   [
            #     categories_disallow.first.first,
            #     categories_disallow.first.third
            #   ]
            # end

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
end
