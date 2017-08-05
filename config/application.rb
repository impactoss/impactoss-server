# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HumanRightsNationalReporting
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Ensure non-standard paths are eager-loaded in production
    # (these paths are also autoloaded in development mode)
    # config.eager_load_paths += %W(#{config.root}/lib)

    config.time_zone = 'Pacific/Auckland'
    config.active_record.default_timezone = :local

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: :any, expose: ['access-token', 'expiry', 'token-type', 'uid', 'client']
      end
    end

    config.middleware.use BatchApi::RackMiddleware do |batch_config|
      # you can set various configuration options:
      batch_config.verb = :post # default :post
      batch_config.endpoint = "/batchapi" # default /batch
      batch_config.limit = 200 # how many operations max per request, default 50

      # default middleware stack run for each batch request
      batch_config.batch_middleware = Proc.new { }
      # default middleware stack run for each individual operation
      batch_config.operation_middleware = Proc.new { }
    end
  end
end
