# frozen_string_literal: true

require "rails_helper"

# on password change, DTA's remove_tokens_after_password_reset
# prunes users.tokens down to the session that completed the change, invalidating
# every other (potentially hijacked) session. Enabled via
#   config.remove_tokens_after_password_reset = true
# in config/initializers/devise_token_auth.rb.
#
# The flag is deliberately NOT stubbed here: if it is ever turned off, the
# keep-newest cases below fail, which is the regression signal we want. (With the
# flag off, the two "unchanged / lone token" cases still pass, since they assert
# no pruning; only the keep-newest and activity-projection cases flip.)
#
# Tokens are hand-built with explicit, distinct expiries so "newest" is
# unambiguous — DTA compares the unix-timestamp expiry. Both are future-dated so
# they survive destroy_expired_tokens, which runs as a before_save just ahead of
# the prune.
RSpec.describe User, "session invalidation on password change", type: :model do
  let(:current_password) { "SecurePassword123!" }

  # Must satisfy the app's secure_password validator and differ from
  # current_password (password_archivable/deny_old_passwords rejects reuse).
  # Adjust if the validator enforces rules beyond length/complexity.
  let(:new_password) { "SecurePassword456!" }

  let(:user) do
    FactoryBot.create(:user, password: current_password, password_confirmation: current_password)
  end

  let(:older_client) { "older-client" }
  let(:newer_client) { "newer-client" }

  def token_entry(expiry)
    {"token" => BCrypt::Password.create("t-#{expiry.to_i}"), "expiry" => expiry.to_i}
  end

  # Two live tokens with distinct future expiries. Saved without a password change
  # so the prune does not fire during setup; reload returns the persisted
  # (string-keyed) form and lets reconcile_token_activities seed the matching
  # token_activities rows.
  def seed_two_tokens!
    user.tokens = {
      older_client => token_entry(1.day.from_now),
      newer_client => token_entry(3.days.from_now)
    }
    user.save!
    user.reload
  end

  def change_password!
    user.password = new_password
    user.password_confirmation = new_password
    user.save!
    user.reload
  end

  it "keeps only the newest-expiry token and drops the rest" do
    seed_two_tokens!
    change_password!
    expect(user.tokens.keys).to eq([newer_client])
  end

  it "leaves all tokens intact when the password is not changed" do
    seed_two_tokens!

    user.name = "Renamed Person"
    user.save!
    user.reload

    expect(user.tokens.keys).to match_array([older_client, newer_client])
  end

  it "leaves a lone token untouched (nothing to prune)" do
    solo_client = "solo-client"
    user.tokens = {solo_client => token_entry(2.days.from_now)}
    user.save!
    user.reload

    change_password!

    expect(user.tokens.keys).to eq([solo_client])
  end

  # The prune is a before_save; User#reconcile_token_activities is an after_save,
  # so it sees the already-pruned tokens hash and drops the activity rows for the
  # invalidated sessions in the same transaction. No wiring specific to the
  # password-change path is needed - this is the same seam that covers sign-out
  # and max_number_of_devices eviction.
  it "prunes the activity rows for the invalidated tokens via reconcile" do
    seed_two_tokens!
    expect(user.token_activities.pluck(:client_id)).to match_array([older_client, newer_client])

    change_password!

    expect(user.token_activities.pluck(:client_id)).to match_array([newer_client])
  end
end
