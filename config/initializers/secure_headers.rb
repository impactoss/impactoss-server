# frozen_string_literal: true

# See https://github.com/twitter/secureheaders#configuration
::SecureHeaders::Configuration.default do |config|
  config.hsts = "max-age=#{20.years.to_i}"
  config.x_frame_options = "SAMEORIGIN"
  config.x_xss_protection = "1; mode=block"
  config.x_content_type_options = "nosniff"
  config.x_permitted_cross_domain_policies = "none"

  config.csp = {
    default_src: %w[https: 'self'],
    child_src: %w['self'],
    connect_src: %w[wss:],
    font_src: %w['self' data:],
    img_src: %w['self' data:],
    object_src: %w['self'],
    script_src: %w['self'],
    style_src: %w['self'],
    base_uri: %w['self'],
    form_action: %w['self'],
    frame_ancestors: %w['self'],
    # block_all_mixed_content: true, deprecated
    upgrade_insecure_requests: !(Rails.env.development? || Rails.env.test?) # see https://www.w3.org/TR/upgrade-insecure-requests/
  }
end
