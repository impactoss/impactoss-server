# frozen_string_literal: true

require "rails_helper"

# Regression coverage for ResetsCurrentCycle's invalidation surface: every
# attribute Category#is_current reads (via the published sibling comparison)
# must actually invalidate the memoised resolver, or a stale answer survives
# past the write that should have changed it.
RSpec.describe "CurrentCycle invalidation", type: :model do
  let(:parent_taxonomy) { FactoryBot.create(:taxonomy) }
  let(:cycle_taxonomy) { FactoryBot.create(:taxonomy, taxonomy: parent_taxonomy) }
  let(:treaty) { FactoryBot.create(:category, taxonomy: parent_taxonomy, draft: false) }
  let!(:current_cycle) do
    FactoryBot.create(:category, taxonomy: cycle_taxonomy, parent_id: treaty.id,
      draft: false, date: Date.new(2025, 1, 1))
  end
  let!(:stale_cycle) do
    FactoryBot.create(:category, taxonomy: cycle_taxonomy, parent_id: treaty.id,
      draft: false, date: Date.new(2020, 1, 1))
  end

  before do
    allow(Rails.application.config.x)
      .to receive(:reporting_cycle_taxonomy_id)
      .and_return(cycle_taxonomy.id)
  end

  it "picks up an archived cycle category without a fresh resolver" do
    recommendation = FactoryBot.create(:recommendation)
    recommendation.categories = [stale_cycle]

    Current.cycle # warm the memo, as a prior request in the same process would
    expect(recommendation.is_current).to eq(false)

    current_cycle.update!(is_archive: true)

    expect(recommendation.is_current).to eq(true)
  end
end
