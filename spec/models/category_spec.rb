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
    let(:category) { FactoryBot.create(:category) }

    # Define allowed roles at class level
    def self.allowed_assign_roles
      @allowed_assign_roles ||= Permissions.roles_with_permission("category", "assign_as_responsible")
    end

    def self.all_roles
      @all_roles ||= Permissions::ROLE_HIERARCHY.keys
    end

    def self.forbidden_assign_roles
      @forbidden_assign_roles ||= all_roles - allowed_assign_roles
    end

    it "does not allow guest users (no roles) to be assigned as manager" do
      user = FactoryBot.create(:user)
      category.manager_id = user.id
      expect { category.save! }.to raise_exception(/must have one of these roles/)
    end

    allowed_assign_roles.each do |role|
      it "allows #{role} users to be assigned as manager" do
        user = FactoryBot.create(:user, role.to_sym)
        expect {
          category.manager_id = user.id
          category.save!
        }.to change { category.reload.manager_id }.from(nil).to(user.id)
      end
    end

    forbidden_assign_roles.each do |role|
      it "does not allow #{role} users to be assigned as manager" do
        user = FactoryBot.create(:user, role.to_sym)
        category.manager_id = user.id
        expect { category.save! }.to raise_exception(/must have one of these roles/)
      end
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

  describe "#is_current" do
    # Shape mirrors production: a treaty category in a parent taxonomy, with
    # its reporting-cycle categories beneath it in the cycle taxonomy.

    let(:parent_taxonomy) { FactoryBot.create(:taxonomy) }
    let(:cycle_taxonomy) { FactoryBot.create(:taxonomy, taxonomy: parent_taxonomy) }
    let(:other_taxonomy) { FactoryBot.create(:taxonomy, taxonomy: parent_taxonomy) }
    let(:treaty) { FactoryBot.create(:category, taxonomy: parent_taxonomy, draft: false) }

    before do
      allow(Rails.application.config.x)
        .to receive(:reporting_cycle_taxonomy_id)
        .and_return(cycle_taxonomy.id)
    end

    # A reporting-cycle category beneath `treaty`.
    def cycle(parent: treaty, taxonomy: cycle_taxonomy, **attrs)
      FactoryBot.create(:category, taxonomy:, parent_id: parent&.id, **attrs)
    end

    context "when it is not in the reporting cycle taxonomy" do
      # Base guard: only categories in the reporting cycle taxonomy qualify.
      it "is not current" do
        category = cycle(taxonomy: other_taxonomy, draft: false, date: Date.new(2024, 1, 1))

        expect(category.is_current).to eq(false)
      end
    end

    context "when the cycle category itself is draft" do
      # A draft cycle still counts as current, otherwise its recommendations
      # are treated as non-current and vanish from the UI.
      it "is current even with no parent and no date" do
        category = FactoryBot.create(:category, taxonomy: cycle_taxonomy, draft: true)

        expect(category.is_current).to eq(true)
      end

      it "is current even when a newer published sibling exists" do
        cycle(draft: false, date: Date.new(2025, 1, 1))
        category = cycle(draft: true, date: Date.new(2020, 1, 1))

        expect(category.is_current).to eq(true)
      end
    end

    context "when the PARENT is draft but the cycle category is published" do
      # The draft check reads self.draft, so a draft parent must not make a
      # published child current.
      it "is not current when it is not the newest published sibling" do
        draft_treaty = FactoryBot.create(:category, taxonomy: parent_taxonomy, draft: true)
        cycle(parent: draft_treaty, draft: false, date: Date.new(2025, 1, 1))
        older = cycle(parent: draft_treaty, draft: false, date: Date.new(2020, 1, 1))

        expect(older.is_current).to eq(false)
      end
    end

    context "when a published cycle category has no parent" do
      # The category.present? guard: with nothing to compare against, a
      # published cycle category is not current.
      it "is not current" do
        category = FactoryBot.create(:category, taxonomy: cycle_taxonomy, draft: false, date: Date.new(2024, 1, 1))

        expect(category.is_current).to eq(false)
      end
    end

    context "when it is the only published child" do
      # An only child is current whether or not it is dated: a date is only
      # needed to rank a category against siblings. This is the shape of
      # production data today - one reporting cycle per treaty.
      it "is current with a date" do
        expect(cycle(draft: false, date: Date.new(2023, 6, 22)).is_current).to eq(true)
      end

      it "is current without a date" do
        expect(cycle(draft: false, date: nil).is_current).to eq(true)
      end

      it "is current when its only siblings are draft" do
        # The sibling lookup is scoped to .published.
        cycle(draft: true, date: Date.new(2025, 1, 1))

        expect(cycle(draft: false, date: nil).is_current).to eq(true)
      end
    end

    context "when there are several published siblings" do
      # The core rule: newest by date wins. This fires once a treaty gains a
      # second reporting cycle.
      let!(:newest) { cycle(draft: false, date: Date.new(2025, 1, 1)) }
      let!(:older) { cycle(draft: false, date: Date.new(2020, 1, 1)) }

      it "is current for the newest by date" do
        expect(newest.is_current).to eq(true)
      end

      it "is not current for an older sibling" do
        expect(older.is_current).to eq(false)
      end

      it "ignores draft siblings when choosing the newest" do
        # A draft sibling with a later date must not win.
        cycle(draft: true, date: Date.new(2030, 1, 1))

        expect(newest.is_current).to eq(true)
      end
    end

    context "when a published sibling has no date" do
      # Undated siblings sort last, so they cannot displace a dated sibling as
      # "newest". They stay non-current themselves via the date.present? guard:
      # with no date there is nothing to rank them by.
      it "leaves the dated sibling current" do
        dated = cycle(draft: false, date: Date.new(2025, 1, 1))
        undated = cycle(draft: false, date: nil)

        expect(dated.is_current).to eq(true)
        expect(undated.is_current).to eq(false)
      end

      # With no dates anywhere there is no "newest", and the date.present?
      # guard keeps every sibling non-current however the rows are ordered.
      it "leaves none of several undated siblings current" do
        first = cycle(draft: false, date: nil)
        second = cycle(draft: false, date: nil)

        expect([first.is_current, second.is_current]).to eq([false, false])
      end
    end

    context "when a sibling is in a different sub-taxonomy" do
      # has_many :categories is keyed on parent_id ONLY - it is not scoped to
      # the reporting cycle taxonomy, and a treaty may carry children in
      # several sub-taxonomies. So a NON-cycle sibling competes in both the
      # only-child count and the ORDER BY.
      it "is not current when an unrelated sibling has a newer date" do
        cycle_category = cycle(draft: false, date: Date.new(2023, 1, 1))
        cycle(taxonomy: other_taxonomy, draft: false, date: Date.new(2025, 1, 1))

        expect(cycle_category.is_current).to eq(false)
      end

      it "is current when the unrelated sibling has an older date" do
        cycle_category = cycle(draft: false, date: Date.new(2023, 1, 1))
        cycle(taxonomy: other_taxonomy, draft: false, date: Date.new(2020, 1, 1))

        expect(cycle_category.is_current).to eq(true)
      end

      it "loses only-child status to an unrelated sibling" do
        cycle_category = cycle(draft: false, date: nil)
        cycle(taxonomy: other_taxonomy, draft: false, date: nil)

        # Without the sibling this is current (only published child, no date
        # required). With it, neither only-child nor the date branch applies.
        expect(cycle_category.is_current).to eq(false)
      end
    end

    context "when siblings share the same date" do
      # Ties break on id, so the winner is defined rather than left to the
      # query plan: exactly one sibling is current, and it is the same one on
      # every call.
      it "leaves the most recently created one current" do
        first = cycle(draft: false, date: Date.new(2024, 1, 1))
        second = cycle(draft: false, date: Date.new(2024, 1, 1))

        expect([first.is_current, second.is_current]).to eq([false, true])
      end
    end

    context "when a sibling is archived" do
      # The published scope filters draft only, so archived siblings still
      # count. Worth pinning because callers pass include_archive=false, which
      # makes it tempting to assume the sibling lookup excludes archived
      # categories. It does not.
      it "is not current when an archived sibling has a newer date" do
        cycle_category = cycle(draft: false, date: Date.new(2023, 1, 1))
        cycle(draft: false, is_archive: true, date: Date.new(2025, 1, 1))

        expect(cycle_category.is_current).to eq(false)
      end

      it "loses only-child status to an archived sibling" do
        cycle_category = cycle(draft: false, date: nil)
        cycle(draft: false, is_archive: true, date: nil)

        expect(cycle_category.is_current).to eq(false)
      end
    end

    context "when a sibling is dated in the future" do
      # Newest-wins has no date <= today guard, so a cycle dated years ahead
      # makes every real cycle non-current from the moment it is entered.
      it "is not current" do
        cycle_category = cycle(draft: false, date: Date.new(2023, 1, 1))
        cycle(draft: false, date: 4.years.from_now.to_date)

        expect(cycle_category.is_current).to eq(false)
      end
    end

    context "when it has no date but its siblings do" do
      # Distinct from the undated-sibling pair below: this pins the
      # date.present? guard on SELF.
      it "is not current" do
        cycle(draft: false, date: Date.new(2024, 1, 1))
        undated = cycle(draft: false, date: nil)

        expect(undated.is_current).to eq(false)
      end
    end
  end
end
