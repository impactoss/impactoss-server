# frozen_string_literal: true

# Writes to the reporting-cycle graph invalidate the memoised CurrentCycle, so
# a request that updates a record and then serialises it sees its own change.
module ResetsCurrentCycle
  extend ActiveSupport::Concern

  included do
    after_commit :reset_current_cycle
  end

  private

  def reset_current_cycle
    Current.cycle_resolver = nil
  end
end
