require "rails_helper"

RSpec.describe Category, type: :model do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to belong_to :taxonomy }
  it { is_expected.to belong_to(:manager).optional }
  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to have_many :recommendations }
  it { is_expected.to have_many :users }
  it { is_expected.to have_many :measures }
  it { is_expected.to have_many :categories }

  context "Sub-relation validations" do
    it "will not allow guest users to be assigned" do
      category = FactoryBot.create(:category)
      user = FactoryBot.create(:user)
      category.manager_id = user.id
      expect { category.save! }.to raise_exception(/Manager must be a manager or an admin/)
    end

    it "will not allow contributor users to be assigned" do
      category = FactoryBot.create(:category)
      user = FactoryBot.create(:user, :contributor)
      category.manager_id = user.id
      expect { category.save! }.to raise_exception(/Manager must be a manager or an admin/)
    end

    it "will allow manager users to be assigned" do
      category = FactoryBot.create(:category)
      user = FactoryBot.create(:user, :manager)
      expect {
        category.manager_id = user.id
        category.save!
      }.to change { category.reload.manager_id }.from(nil).to(user.id)
    end

    it "will allow admin users to be assigned" do
      category = FactoryBot.create(:category)
      user = FactoryBot.create(:user, :admin)
      expect {
        category.manager_id = user.id
        category.save!
      }.to change { category.reload.manager_id }.from(nil).to(user.id)
    end

    it "Should update parent_id with correct taxonomy relation" do
      category = FactoryBot.create(:category, :parent_category)
      sub_category = FactoryBot.create(:category, :sub_category)
      taxonomy = FactoryBot.create(:taxonomy, :sub_taxonomy)

      sub_category.taxonomy_id = taxonomy.id
      category.taxonomy_id = taxonomy.parent_id
      sub_category.save!
      category.save!

      sub_category.parent_id = category.id
      sub_category.save!
    end

    it "Should not update parent_id if parent is already a sub-category" do
      category = FactoryBot.create(:category)
      parent_category = FactoryBot.create(:category, :parent_category)
      sub_category = FactoryBot.create(:category, :sub_category)
      taxonomy = FactoryBot.create(:taxonomy, :sub_taxonomy)

      parent_category.taxonomy_id = taxonomy.id
      category.taxonomy_id = taxonomy.parent_id
      category.save!

      parent_category.parent_id = category.id
      parent_category.save!

      sub_category.parent_id = parent_category.id
      expect { sub_category.save! }.to raise_exception(/Parent category is already a sub-category./)
    end

    it "Should not update parent_id with incorrect taxonomy relation" do
      category = FactoryBot.create(:category, :parent_category)
      sub_category = FactoryBot.create(:category, :sub_category)
      sub_category.parent_id = category.id
      expect { sub_category.save! }.to raise_exception(/Validation failed: Parent Taxonomy does not have parent category's taxonomy as parent./)
    end
  end

  describe "indicators" do
    subject { FactoryBot.create(:category) }

    let(:indicator_traits) { [] }

    let(:child_taxonomy) { FactoryBot.create(:taxonomy, parent_id: subject.taxonomy.id) }
    let(:child_category) { FactoryBot.create(:category, parent_id: subject.id, title: "Child Category", taxonomy: child_taxonomy) }

    let(:first_recommendation) { FactoryBot.create(:recommendation, title: "First Recommendation") }
    let(:second_recommendation) { FactoryBot.create(:recommendation, title: "Second Recommendation") }
    let(:child_category_recommendation) { FactoryBot.create(:recommendation, title: "Child Category Recommendation") }

    let(:first_direct_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "First Direct Indicator") }
    let(:second_direct_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "Second Direct Indicator") }
    let(:third_direct_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "Second Direct Indicator") }

    let(:indicator_via_first_measure) { FactoryBot.create(:indicator, *indicator_traits, title: "Indicator via First Measure") }
    let(:indicator_via_second_measure) { FactoryBot.create(:indicator, *indicator_traits, title: "Indicator via Second Measure") }

    let(:first_shared_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "First Shared Indicator") }
    let(:second_shared_indicator) { FactoryBot.create(:indicator, *indicator_traits, title: "Second Shared Indicator") }

    let(:first_measure) { FactoryBot.create(:measure) }
    let(:second_measure) { FactoryBot.create(:measure) }

    let(:all_unique_indicators) do
      [
        first_direct_indicator,
        second_direct_indicator,
        third_direct_indicator,
        indicator_via_first_measure,
        indicator_via_second_measure,
        first_shared_indicator,
        second_shared_indicator
      ]
    end

    before do
      # Create direct indicators: two for the first recommendation, one for the second, and one for the child category recommendation
      FactoryBot.create(:recommendation_indicator, recommendation: first_recommendation, indicator: first_direct_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: first_recommendation, indicator: second_direct_indicator)

      FactoryBot.create(:recommendation_indicator, recommendation: second_recommendation, indicator: second_direct_indicator)

      FactoryBot.create(:recommendation_indicator, recommendation: child_category_recommendation, indicator: third_direct_indicator)

      # Create indicators via measures
      FactoryBot.create(:measure_indicator, measure: first_measure, indicator: indicator_via_first_measure)
      FactoryBot.create(:measure_indicator, measure: second_measure, indicator: indicator_via_second_measure)

      # Associate measures with the recommendation: one for the first recommendation, two for the second, and one for the child category recommendation
      FactoryBot.create(:recommendation_measure, recommendation: first_recommendation, measure: first_measure)

      FactoryBot.create(:recommendation_measure, recommendation: second_recommendation, measure: first_measure)
      FactoryBot.create(:recommendation_measure, recommendation: second_recommendation, measure: second_measure)

      FactoryBot.create(:recommendation_measure, recommendation: child_category_recommendation, measure: second_measure)

      # Create shared indicators: both linked to every recommendation
      FactoryBot.create(:measure_indicator, measure: first_measure, indicator: first_shared_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: first_recommendation, indicator: first_shared_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: second_recommendation, indicator: first_shared_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: child_category_recommendation, indicator: first_shared_indicator)

      FactoryBot.create(:measure_indicator, measure: second_measure, indicator: second_shared_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: first_recommendation, indicator: second_shared_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: second_recommendation, indicator: second_shared_indicator)
      FactoryBot.create(:recommendation_indicator, recommendation: child_category_recommendation, indicator: second_shared_indicator)

      # Associate recommendations to the category
      FactoryBot.create(:recommendation_category, recommendation: first_recommendation, category: subject)
      FactoryBot.create(:recommendation_category, recommendation: second_recommendation, category: subject)

      # Associate child category
      FactoryBot.create(:recommendation_category, recommendation: child_category_recommendation, category: child_category)
    end

    describe "#combined_indicator_ids" do
      it "contains the IDs of all distinct indicators from recommendations and the recommendations of child categories" do
        expect(subject.combined_indicator_ids).not_to be_empty
        expect(subject.combined_indicator_ids).to match_array(all_unique_indicators.map(&:id))
      end
    end

    describe "#due_dates" do
      let(:indicator_traits) { [:with_12_due_dates] }

      it "contains the due dates for all distinct indicators from recommendations and the recommendations of child categories" do
        expect(subject.due_dates.to_a).not_to be_empty
        expect(subject.due_dates.to_a).to match_array(all_unique_indicators.flat_map(&:due_dates))
      end
    end
  end
end
