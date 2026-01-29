# frozen_string_literal: true

Rails.application.routes.draw do
  mount_devise_token_auth_for "User",
    at: "auth",
    controllers: {
      sessions: "sessions",
      omniauth_callbacks: "impact_omniauth_callbacks"
    }

  resources :taxonomies do
    resources :categories
  end
  get "static_pages/home"
  get "s3/sign"
  get "features", to: "features#index"

  resources :categories
  resources :recommendations
  resources :users
  resources :roles
  resources :pages
  resources :bookmarks
  resources :frameworks, only: [:index, :show]
  resources :user_roles, only: [:index, :show, :create, :destroy]
  resources :recommendation_categories, only: [:index, :show, :create, :destroy]
  resources :user_categories, only: [:index, :show, :create, :destroy]
  resources :framework_frameworks, only: [:index, :show]
  resources :framework_taxonomies, only: [:index, :show]

  resources :measures if Features.enabled?(:measures)
  resources :indicators if Features.enabled?(:indicators)
  resources :progress_reports if Features.enabled?(:progress_reports)
  resources :due_dates if Features.enabled?(:progress_reports)
  resources :measure_categories, only: [:index, :show, :create, :destroy] if Features.enabled?(:measures)
  resources :measure_indicators, only: [:index, :show, :create, :destroy] if Features.enabled?(:measures) && Features.enabled?(:indicators)
  resources :recommendation_measures, only: [:index, :show, :create, :destroy] if Features.enabled?(:measures)
  resources :recommendation_indicators, only: [:index, :show, :create, :destroy] if Features.enabled?(:indicators)
  resources :recommendation_recommendations, only: [:index, :show, :create, :destroy]

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root to: "static_pages#home"
end
