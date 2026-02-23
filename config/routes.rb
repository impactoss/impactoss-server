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
    skip: [:omniauth_callbacks, :registrations]

  # Manually define registration routes without destroy
  post "auth", to: "registrations#create", as: :user_registration
  put "auth", to: "registrations#update", as: :update_user_registration

  get "s3/sign" if ENV["AWS_ACCESS_KEY_ID"].present?
  # get "features", to: "features#index"

  # index only: set up on server
  resources :due_dates, only: [:index] if Features.enabled?(:progress_reports)
  resources :frameworks, only: [:index]
  resources :framework_frameworks, only: [:index] if Features.enabled?(:framework_parents)
  resources :framework_taxonomies, only: [:index]
  resources :roles, only: [:index]
  resources :taxonomies, only: [:index]
  # full CRUD
  resources :bookmarks, only: [:index, :create, :update, :destroy]
  resources :categories, only: [:index, :create, :update, :destroy]
  resources :indicators, only: [:index, :create, :update, :destroy] if Features.enabled?(:indicators)
  resources :measures, only: [:index, :create, :update, :destroy] if Features.enabled?(:measures)
  resources :pages, only: [:index, :create, :update, :destroy]
  resources :progress_reports, only: [:index, :create, :update, :destroy] if Features.enabled?(:progress_reports)
  resources :recommendations, only: [:index, :create, :update, :destroy]
  # users: only indes and update. creation ohnly via registration /auth
  resources :users, only: [:index, :update]
  # CRD only - joins are only created or deleted, never changed
  resources :measure_categories, only: [:index, :create, :destroy] if Features.enabled?(:measures)
  resources :measure_indicators, only: [:index, :create, :destroy] if Features.enabled?(:measures) && Features.enabled?(:indicators)
  resources :recommendation_categories, only: [:index, :create, :destroy]
  resources :recommendation_indicators, only: [:index, :create, :destroy] if Features.enabled?(:indicators)
  resources :recommendation_measures, only: [:index, :create, :destroy] if Features.enabled?(:measures)
  resources :user_roles, only: [:index, :create, :destroy]
  resources :user_categories, only: [:index, :create, :destroy] if Features.enabled?(:progress_reports)
  resources :recommendation_recommendations, only: [:index, :create, :destroy] if Features.enabled?(:recommendation_parents)

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root to: proc { [200, {"Content-Type" => "application/json"}, ['{"status":"ok"}']] }
end
