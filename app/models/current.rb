# frozen_string_literal: true

# Request-scoped state. Rails resets this between requests, and between jobs,
# so nothing leaks from one unit of work to the next.
class Current < ActiveSupport::CurrentAttributes
  attribute :cycle_resolver

  # Memoised for the life of the request: is_current is asked of every record
  # twice (once to filter, once to serialise), and the answer cannot change
  # underneath us without a write - which resets it, see ResetsCurrentCycle.
  def cycle
    self.cycle_resolver ||= CurrentCycle.new
  end
end
