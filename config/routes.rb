# frozen_string_literal: true
Rails.application.routes.draw do
  resources :actions
  resources :recommendations
  resources :indicators

  devise_for :users
  resources :users

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root to: "dashboards#show"
end
