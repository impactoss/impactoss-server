# frozen_string_literal: true

# Per-token (client-id) activity store backing the server-side inactivity
# timeout for devise_token_auth sessions.
#
# One row per live token; the invariant "token exists <=> activity row exists"
# is maintained by User#reconcile_token_activities (an after_save on User that
# runs inside the same transaction as token issuance/eviction).
#
# Deliberately:
# * inherits from ApplicationRecord, NOT VersionedRecord, so these frequent
#   heartbeat writes are not captured by PaperTrail;
# * lives in its own table so activity writes stay off the users row, which
#   would otherwise re-introduce the batch write-contention that forced token
#   rotation (change_headers_on_each_request) off.
class TokenActivity < ApplicationRecord
  belongs_to :user

  validates :client_id, presence: true

  # Configured in config/initializers/session_timeout.rb.
  def self.inactivity_timeout
    Rails.application.config.x.session_timeout.inactivity
  end

  def self.coalesce_window
    Rails.application.config.x.session_timeout.heartbeat_coalesce_window
  end

  def stale?
    last_activity_at < self.class.inactivity_timeout.ago
  end

  def stale_for_heartbeat?
    last_activity_at < self.class.coalesce_window.ago
  end

  # Seconds until this token expires from inactivity, floored at zero.
  def seconds_remaining(now = Time.current)
    [(last_activity_at + self.class.inactivity_timeout - now).to_i, 0].max
  end
end
