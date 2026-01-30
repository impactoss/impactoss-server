# frozen_string_literal: true

# Multi-Factor Authentication Configuration
#
# Set IMPACTOSS_REQUIRE_MFA=true in your environment to require MFA for all users.
# When enabled, all users must verify their email with an OTP code when signing in.
#
Rails.application.config.enable_mfa = ENV.fetch("IMPACTOSS_REQUIRE_MFA", "false") == "true"
