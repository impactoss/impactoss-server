# frozen_string_literal: true

# Server-side inactivity timeout for devise_token_auth sessions.
#
# Token rotation is disabled (change_headers_on_each_request = false) because
# batch imports fire many concurrent requests, so DTA's native sliding expiry
# is unavailable. This concern enforces an inactivity timeout instead:
#
# * every authenticated request reads the presenting token's activity row and
#   rejects if it is stale or missing (fail closed); a still-live token never
#   writes anything, so batch requests do zero activity writes;
# * only the client heartbeat (TokenActivitiesController) writes the timestamp
#   for a live token, coalesced so the write rate stays ~1 per token/window;
# * killing a token removes it from users.tokens too - see
#   expire_current_token! below - so tokens and activity rows stay in sync.
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
    #
    # current_token_client.present? fails OPEN if it's ever false, but DTA's
    # set_user_by_token defaults client to "default" whenever none is
    # supplied, on the same path that sets current_user - so it should always
    # be present here.
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
    return unless activity.nil? || activity.stale?

    expire_current_token!
    reject_expired_session
  end

  # A killed token (stale or missing row) must not survive in users.tokens
  # either - otherwise the next unrelated User#save has
  # User#reconcile_token_activities (tokens is authoritative there) recreate
  # the row with a fresh window, reviving the expired session. This is the one
  # write enforcement performs, and only on this rare token-killing path.
  #
  # save!(validate: false): this write only removes a client_id, never touches
  # user input, and must not turn a 401 into a 422 on an unrelated validation
  # failure. Transaction: so a raised error can't leave the row deleted but
  # the token still present, reopening the same divergence.
  #
  # Lost-update note: current_user was loaded at authentication, so this save
  # can drop a token issued concurrently (sign-in, clean_old_tokens) in
  # between. Self-limiting - once a token is out of tokens, DTA's
  # set_user_by_token returns nil and later requests 401 before reaching here.
  def expire_current_token!
    current_user.transaction do
      current_user.token_activities.where(client_id: current_token_client).delete_all
      next unless (current_user.tokens || {}).key?(current_token_client)

      current_user.tokens.delete(current_token_client)
      current_user.save!(validate: false)
    end
  end

  def reject_expired_session
    render json: {
      success: false,
      errors: [I18n.t("devise_token_auth.sessions.expired",
        default: "Your session has expired due to inactivity. Please sign in again.")]
    }, status: :unauthorized
  end
end
