# frozen_string_literal: true

# Client heartbeat endpoint feeding the server-side inactivity timeout.
#
# The SPA pings this (gated on real user interaction) so that no-request
# activity - filtering lists, composing markdown, building exports - still
# refreshes the session. This is the ONLY writer of last_activity_at; normal
# API requests read-and-enforce only.
#
# TokenActivityEnforcement (a before_action inherited from ApplicationController)
# runs first, so a ping arriving after the threshold is rejected before this
# action writes - a late stray interaction cannot resurrect an expired session.
class TokenActivitiesController < ApplicationController
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false

  # POST /auth/activity
  def create
    activity = current_user.token_activities.find_by(client_id: current_token_client)

    # Enforcement guarantees a fresh row here; guard defensively regardless.
    if activity&.stale_for_heartbeat?
      activity.update_column(:last_activity_at, Time.current)
    end

    head :no_content
  end
end
