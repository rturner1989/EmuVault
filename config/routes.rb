Rails.application.routes.draw do
  root "dashboard#index"

  resource :session
  resource :password, only: %i[edit update]
  resource :setup, only: %i[show update], controller: "setup" do
    get :profiles
    post :select_profiles
    get :configure
    patch :save_configuration
    get :library
    patch :save_library
  end
  resource :settings, only: %i[show update]
  resource :current_game, only: %i[update destroy], controller: "current_game"
  get "directory_browser", to: "directory_browser#show"
  resources :scan_paths, only: %i[create update destroy]
  resource :library_scan, only: %i[create] do
    get  :review
    post :confirm
  end

  resources :data_exports, only: %i[create]
  resources :data_imports, only: %i[create] do
    member do
      get   :review
      patch :resolve
    end
  end

  resources :games do
    resource :emulator_configs, only: [:update], controller: "game_emulator_configs"
    resources :game_saves, only: %i[create destroy] do
      member do
        get :download
      end
    end
  end
  resource :activity, only: [:show], controller: "activity"
  resources :emulator_profiles do
    collection do
      get  :library
      get  :library_system
      post :add_from_library
    end
  end

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
