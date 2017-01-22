# frozen_string_literal: true
Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :taxonomies do
    resources :categories
  end
  get 'static_pages/home'

  resources :categories
  resources :indicators
  resources :measures
  resources :recommendations
  resources :due_dates
  resources :measure_categories
  resources :measure_indicators
  resources :recommendation_categories
  resources :recommendation_measures
  resources :progress_reports
  resources :users

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root to: 'static_pages#home'
end
