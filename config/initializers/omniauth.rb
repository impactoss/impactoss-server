Rails.application.config.middleware.use OmniAuth::Builder do
  provider :azure_activedirectory_v2, {
    callback_path: "/auth/azure_oauth2/callback",
    client_id: ENV["AZURE_CLIENT_ID"],
    client_secret: ENV["AZURE_CLIENT_SECRET"],
    provider_ignores_state: ENV.fetch("AZURE_PROVIDER_IGNORES_STATE", "false") == "true",
    tenant_id: ENV["AZURE_TENANT_ID"]
  }

  # By default only POST is supported but, for now, we need GET for our redirect.
  OmniAuth.config.allowed_request_methods = %i[get post]
  OmniAuth.config.silence_get_warning = true
end
