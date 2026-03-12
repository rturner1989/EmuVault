Rails.application.routes.draw do
  root "dashboard#index"

  resource :session
  resource :password, only: %i[edit update]
  resource :settings, only: %i[show] do
    post :regenerate_token, on: :collection
  end

  resources :games do
    resources :game_saves, only: %i[create destroy] do
      member do
        get :download
      end
    end
  end
  resources :devices
  resources :emulator_profiles, only: %i[index]

  namespace :api do
    resources :game_saves, only: %i[index show] do
      member do
        get :file
      end
    end
  end

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
  mount ActionCable.server => "/cable"

  get "up" => "rails/health#show", as: :rails_health_check
end
