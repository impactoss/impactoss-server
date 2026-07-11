# frozen_string_literal: true

# Server-side inactivity timeout for devise_token_auth sessions.
#
# Token rotation is disabled (change_headers_on_each_request = false) because
# batch imports fire many concurrent requests, so DTA's native sliding expiry
# is unavailable. This concern enforces an inactivity timeout instead:
#
# * every authenticated request READS (never writes) the presenting token's
#   activity row and rejects if it is stale or missing (fail closed);
# * only the client heartbeat (TokenActivitiesController) writes the timestamp,
#   so batch requests do zero activity writes.
#
# See TokenActivity for the store and the create-at-login invariant.
module TokenActivityEnforcement
  extend ActiveSupport::Concern

  included do
    before_action :enforce_session_activity_timeout, if: :enforce_activity_timeout?
  end

  private

  def enforce_activity_timeout?
    # Only guard genuinely authenticated requests. Sign-in/sign-out run through
    # SessionsController and must not be blocked by an already-expired session.
    current_user.present? &&
      current_token_client.present? &&
      !is_a?(DeviseTokenAuth::SessionsController)
  end

  # The client-id of the token presented on this request, set by DTA's
  # set_user_by_token during authentication.
  def current_token_client
    @token&.client
  end

  def enforce_session_activity_timeout
    activity = current_user.token_activities.find_by(client_id: current_token_client)

    # Invariant: a live token always has an activity row (created at issuance).
    # A missing row is a should-never-happen state -> fail closed.
    return reject_expired_session if activity.nil?
    return unless activity.stale?

    # Past the threshold: drop the row so the token is dead by the missing-row
    # rule on any subsequent request, without writing to users.tokens on the
    # hot path. The token entry itself is reaped later by token_lifespan.
    activity.destroy
    reject_expired_session
  end

  def reject_expired_session
    render json: {
      success: false,
      errors: [I18n.t("devise_token_auth.sessions.expired",
        default: "Your session has expired due to inactivity. Please sign in again.")]
    }, status: :unauthorized
  end
end
