require "rails_helper"

# Unstubbed coverage of how is_current propagates up the graph:
#
#   ProgressReport -> indicator -> measures -> recommendations -> categories
#
# Every level is exercised against real records: stubbing is_current on one
# loaded instance only proves the stub was reached, not that the rule holds.
RSpec.describe "is_current propagation", type: :model do
  let(:parent_taxonomy) { FactoryBot.create(:taxonomy) }
  let(:cycle_taxonomy) { FactoryBot.create(:taxonomy, taxonomy: parent_taxonomy) }
  let(:other_taxonomy) { FactoryBot.create(:taxonomy, taxonomy: parent_taxonomy) }
  let(:treaty) { FactoryBot.create(:category, taxonomy: parent_taxonomy, draft: false) }

  # Two dated cycles under one treaty: newest wins, older does not. This is the
  # shape production takes at the first reporting cycle transition.
  let!(:current_cycle) do
    FactoryBot.create(:category, taxonomy: cycle_taxonomy, parent_id: treaty.id,
      draft: false, date: Date.new(2025, 1, 1))
  end
  let!(:stale_cycle) do
    FactoryBot.create(:category, taxonomy: cycle_taxonomy, parent_id: treaty.id,
      draft: false, date: Date.new(2020, 1, 1))
  end
  let(:unrelated_category) do
    FactoryBot.create(:category, taxonomy: other_taxonomy, draft: false)
  end

  before do
    allow(Rails.application.config.x)
      .to receive(:reporting_cycle_taxonomy_id)
      .and_return(cycle_taxonomy.id)
  end

  def recommendation_with(*categories)
    FactoryBot.create(:recommendation).tap { _1.categories = categories }
  end

  def measure_with(*recommendations)
    FactoryBot.create(:measure).tap { _1.recommendations = recommendations }
  end

  def indicator_with(*measures)
    FactoryBot.create(:indicator).tap { _1.measures = measures }
  end

  describe "the fixture itself" do
    # Guards the rest of the file: if these two flip, every expectation below
    # becomes meaningless rather than failing for its own reason.
    it "has one current and one stale cycle category" do
      expect(current_cycle.is_current).to eq(true)
      expect(stale_cycle.is_current).to eq(false)
    end
  end

  describe "Recommendation#is_current" do
    it "is current with no categories at all" do
      expect(recommendation_with.is_current).to eq(true)
    end

    it "is current when linked only to non-cycle categories" do
      # Not linked to a reporting cycle means always current.
      expect(recommendation_with(unrelated_category).is_current).to eq(true)
    end

    it "is current when linked to the current cycle" do
      expect(recommendation_with(current_cycle).is_current).to eq(true)
    end

    it "is not current when linked only to a stale cycle" do
      expect(recommendation_with(stale_cycle).is_current).to eq(false)
    end

    it "is not current when a non-cycle category accompanies a stale cycle" do
      # The none? short-circuit is defeated by the presence of ANY cycle
      # category, so the unrelated category does not rescue it.
      expect(recommendation_with(unrelated_category, stale_cycle).is_current).to eq(false)
    end

    it "is current when any one of its cycles is current" do
      expect(recommendation_with(stale_cycle, current_cycle).is_current).to eq(true)
    end
  end

  describe "Measure#is_current" do
    it "is current with no recommendations" do
      expect(measure_with.is_current).to eq(true)
    end

    it "is not current when all its recommendations are stale" do
      expect(measure_with(recommendation_with(stale_cycle)).is_current).to eq(false)
    end

    it "is current when any recommendation is current" do
      measure = measure_with(recommendation_with(stale_cycle), recommendation_with(current_cycle))

      expect(measure.is_current).to eq(true)
    end
  end

  describe "Indicator#is_current" do
    it "is current with no measures" do
      expect(indicator_with.is_current).to eq(true)
    end

    it "is not current when all its measures are stale" do
      stale_measure = measure_with(recommendation_with(stale_cycle))

      expect(indicator_with(stale_measure).is_current).to eq(false)
    end

    it "is current when any measure is current" do
      stale_measure = measure_with(recommendation_with(stale_cycle))
      current_measure = measure_with(recommendation_with(current_cycle))

      expect(indicator_with(stale_measure, current_measure).is_current).to eq(true)
    end

    it "is current when a measure has no recommendations of its own" do
      # The empty? rule at the Measure level propagates upwards.
      expect(indicator_with(measure_with).is_current).to eq(true)
    end
  end

  describe "ProgressReport#is_current" do
    it "follows a current indicator" do
      indicator = indicator_with(measure_with(recommendation_with(current_cycle)))

      expect(FactoryBot.create(:progress_report, indicator:).is_current).to eq(true)
    end

    it "follows a stale indicator" do
      indicator = indicator_with(measure_with(recommendation_with(stale_cycle)))

      expect(FactoryBot.create(:progress_report, indicator:).is_current).to eq(false)
    end
  end
end
