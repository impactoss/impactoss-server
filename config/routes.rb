# frozen_string_literal: true
Rails.application.routes.draw do
  resources :taxonomies do
    resources :categories
  end
  resources :indicators
  resources :measures
  resources :recommendations
  devise_for :users
  resources :users

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root to: 'dashboards#show'
end
