# frozen_string_literal: true
Rails.application.routes.draw do
  resources :static_pages

  root 'static_pages#index'
  devise_for :users
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  root to: "dashboards#show"
end
