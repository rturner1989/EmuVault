Rails.application.routes.draw do
  root "dashboard#index"

  resource :session
  resource :password, only: %i[edit update]
  resource :setup, only: %i[show update], controller: "setup" do
    get :profiles
    post :select_profiles
    get :configure
    patch :save_configuration
  end
  resource :settings, only: %i[show]

  resources :games do
    resource :emulator_configs, only: [:update], controller: "game_emulator_configs"
    resources :game_saves, only: %i[create destroy] do
      member do
        get :download
      end
    end
  end
  resource :activity, only: [:show], controller: "activity"
  resources :emulator_profiles

  resources :notifications, only: %i[index show] do
    collection do
      patch :mark_all_read
    end
  end
  resources :web_push_subscriptions, only: %i[create destroy]

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  mount PgHero::Engine => "/pghero"
  mount ActionCable.server => "/cable"

  get "up" => "rails/health#show", as: :rails_health_check
end
