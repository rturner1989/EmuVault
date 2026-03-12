Rails.application.routes.draw do
  root "dashboard#index"

  resource :session
  resource :password, only: %i[edit update]

  resources :games
  resources :devices
  resources :emulator_profiles, only: %i[index]

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
  mount ActionCable.server => "/cable"

  get "up" => "rails/health#show", as: :rails_health_check
end
