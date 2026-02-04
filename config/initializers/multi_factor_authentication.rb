# frozen_string_literal: true

##
# Authentication Configuration
#
# Controls authentication methods and MFA requirements.
#
# Environment Variables:
#   IMPACTOSS_ENABLE_AZURE         - Enable Azure/EntraID SSO (true/false)
#   IMPACTOSS_REQUIRE_MFA          - Require MFA for local auth (true/false)
#   IMPACTOSS_MFA_METHODS          - Available MFA methods (comma-separated)
#                                    Options: email_otp, totp
#                                    Default: email_otp
#
# Examples:
#   # Email/password with email OTP
#   IMPACTOSS_REQUIRE_MFA=true
#   IMPACTOSS_MFA_METHODS=email_otp
#
#   # Email/password with choice of TOTP or email OTP
#   IMPACTOSS_REQUIRE_MFA=true
#   IMPACTOSS_MFA_METHODS=totp,email_otp
#
#   # Azure SSO with TOTP for local accounts
#   IMPACTOSS_ENABLE_AZURE=true
#   IMPACTOSS_REQUIRE_MFA=true
#   IMPACTOSS_MFA_METHODS=totp
#
Rails.application.config.tap do |config|
  # Primary authentication
  config.enable_azure = ENV.fetch("IMPACTOSS_ENABLE_AZURE", "false") == "true"

  # Multi-factor authentication
  config.require_mfa = ENV.fetch("IMPACTOSS_REQUIRE_MFA", "false") == "true"

  mfa_methods_string = ENV.fetch("IMPACTOSS_MFA_METHODS", "email_otp")
  config.mfa_methods = mfa_methods_string.split(",").map(&:strip).map(&:to_sym)

  # Maintain backward compatibility with old config name
  config.enable_mfa = config.require_mfa && config.mfa_methods.include?(:email_otp)
end
