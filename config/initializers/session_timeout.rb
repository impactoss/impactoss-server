# frozen_string_literal: true

# Server-side inactivity timeout for devise_token_auth sessions.
#
# See TokenActivity (the per-token activity store) and TokenActivityEnforcement
# (the read-only before_action that rejects idle sessions). Token rotation is
# off, so these drive the timeout instead of DTA's native sliding expiry.
Rails.application.config.x.session_timeout.tap do |session_timeout|
  # Reject a token whose last recorded activity is older than this.
  session_timeout.inactivity = 30.minutes

  # The heartbeat only rewrites last_activity_at once it is at least this stale,
  # keeping the write rate to ~1 per token per window regardless of ping cadence.
  session_timeout.heartbeat_coalesce_window = 2.minutes
end
