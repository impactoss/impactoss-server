# frozen_string_literal: true

Rails.application.routes.draw do
  # Multi-factor authentication endpoints - must come before devise mount
  post "auth/verify_multi_factor", to: "multi_factor#verify"
  post "auth/resend_multi_factor", to: "multi_factor#resend"

  controllers_config = {
    sessions: "sessions",
    registrations: "registrations",
    passwords: "passwords"
  }
  controllers_config[:omniauth_callbacks] = "impact_omniauth_callbacks" if ENV["AZURE_CLIENT_ID"].present?

  mount_devise_token_auth_for "User",
    at: "auth",
    controllers: controllers_config,
    skip: [:omniauth_callbacks]

  get "s3/sign" if ENV["AWS_ACCESS_KEY_ID"].present?
  # get "features", to: "features#index"

  resources :taxonomies, except: [:new, :edit]
  resources :categories, except: [:new, :edit]
  resources :recommendations, except: [:new, :edit]
  resources :users, except: [:new, :edit]
  resources :roles, except: [:new, :edit]
  resources :pages, except: [:new, :edit]
  resources :bookmarks, except: [:new, :edit]
  resources :frameworks, only: [:index, :show]
  resources :user_roles, only: [:index, :show, :create, :destroy]
  resources :recommendation_categories, only: [:index, :show, :create, :destroy]
  resources :user_categories, only: [:index, :show, :create, :destroy]
  resources :framework_frameworks, only: [:index, :show]
  resources :framework_taxonomies, only: [:index, :show]

  resources :measures, except: [:new, :edit] if Features.enabled?(:measures)
  resources :indicators, except: [:new, :edit] if Features.enabled?(:indicators)
  resources :progress_reports, except: [:new, :edit] if Features.enabled?(:progress_reports)
  resources :due_dates, except: [:new, :edit] if Features.enabled?(:progress_reports)
  resources :measure_categories, only: [:index, :show, :create, :destroy] if Features.enabled?(:measures)
  resources :measure_indicators, only: [:index, :show, :create, :destroy] if Features.enabled?(:measures) && Features.enabled?(:indicators)
  resources :recommendation_measures, only: [:index, :show, :create, :destroy] if Features.enabled?(:measures)
  resources :recommendation_indicators, only: [:index, :show, :create, :destroy] if Features.enabled?(:indicators)
  resources :recommendation_recommendations, only: [:index, :show, :create, :destroy]

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root to: proc { [200, {"Content-Type" => "application/json"}, ['{"status":"ok"}']] }
end
