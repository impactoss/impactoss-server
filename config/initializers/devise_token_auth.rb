DeviseTokenAuth.setup do |config|
  config.send_confirmation_email = false
  # By default the authorization headers will change after each request. The
  # client is responsible for keeping track of the changing tokens. Change
  # this to false to prevent the Authorization header from changing after
  # each request.
  config.change_headers_on_each_request = false

  # By default, users will need to re-authenticate after 2 weeks. This setting
  # determines how long tokens will remain valid after they are issued.
  # config.token_lifespan = 2.weeks

  # Sets the max number of concurrent devices per user, which is 10 by default.
  # After this limit is reached, the oldest tokens will be removed.
  config.max_number_of_devices = 2

  # Sometimes it's necessary to make several requests to the API at the same
  # time. In this case, each request in the batch will need to share the same
  # auth token. This setting determines how far apart the requests can be while
  # still using the same auth token.
  # config.batch_request_buffer_throttle = 5.seconds

  # This route will be the prefix for all oauth2 redirect callbacks. For
  # example, using the default '/omniauth', the github oauth2 provider will
  # redirect successful authentications to '/omniauth/github/callback'
  config.omniauth_prefix = "/auth"

  # By default sending current password is not needed for the password update.
  # Uncomment to enforce current_password param to be checked before all
  # attribute updates. Set it to :password if you want it to be checked only if
  # password is updated.
  config.check_current_password_before_update = :password

  # By default we will use callbacks for single omniauth.
  # It depends on fields like email, provider and uid.
  # config.default_callbacks = true

  # Makes it possible to change the headers names
  # config.headers_names = {:'access-token' => 'access-token',
  #                        :'client' => 'client',
  #                        :'expiry' => 'expiry',
  #                        :'uid' => 'uid',
  #                        :'token-type' => 'token-type' }

  # By default, only Bearer Token authentication is implemented out of the box.
  # If, however, you wish to integrate with legacy Devise authentication, you can
  # do so by enabling this flag. NOTE: This feature is highly experimental!
  # config.enable_standard_devise_support = false

  # IMPORTANT: Disable bypass_sign_in for API-only mode (no sessions)
  config.bypass_sign_in = false

  # When a user's password changes, drop all of their auth tokens except the one
  # on the request that made the change, invalidating every other active session.
  # Addresses pentest finding 3.2.1-C: without this, stock DTA leaves other tokens
  # in place, so a hijacked session survives a legitimate password reset.
  #
  # Trigger is any encrypted_password change, not only the forgot-password flow —
  # an in-app change or the password_expirable forced change clears other sessions
  # too. The retained token is the newest by expiry, which in the reset flow is the
  # session that completed the change.
  config.remove_tokens_after_password_reset = true
end

# WORKAROUND: devise_token_auth 1.2.5+ (required for Rails 8) auto-adds :confirmable
# We have the required DB columns (confirmed_at, confirmation_token, confirmation_sent_at)
# but we don't use email confirmation - our MFA flow already verifies email ownership.
# This prevents Devise from triggering unwanted confirmation emails.
Rails.application.config.after_initialize do
  User.devise_modules.delete(:confirmable)

  # Also remove from Devise's list of modules
  Devise.mappings[:user]&.modules&.delete(:confirmable)
end

Devise.mailer = "CustomDeviseMailer"
