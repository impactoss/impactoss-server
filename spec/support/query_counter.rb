# frozen_string_literal: true

# Counts SQL queries issued during the block, for asserting an equality
# across fixture sizes rather than pinning an exact count (which drifts with
# unrelated changes - see CurrentCycle). Counts cached reads too: a cache hit
# skips the database but still costs Ruby, and an N+1 shows up largely as
# cached queries once the first record has warmed the query cache. Excludes
# only Rails' own SCHEMA/TRANSACTION housekeeping.
module QueryCounter
  def count_queries
    count = 0
    counter = lambda do |*, payload|
      count += 1 unless %w[SCHEMA TRANSACTION].include?(payload[:name])
    end

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
      yield
    end

    count
  end
end

RSpec.configure do |config|
  config.include QueryCounter
end
