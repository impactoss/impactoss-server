# frozen_string_literal: true

# Writes to the reporting-cycle graph invalidate the memoised CurrentCycle, so
# a request that updates a record and then serialises it sees its own change.
#
# Only provides the reset method - each includer wires up its own
# after_commit, scoped to the writes that can actually change a CurrentCycle
# answer. See Category and the join models (RecommendationCategory,
# RecommendationMeasure, MeasureIndicator) for the two shapes in use.
module ResetsCurrentCycle
  extend ActiveSupport::Concern

  private

  def reset_current_cycle
    Current.cycle_resolver = nil
  end
end
