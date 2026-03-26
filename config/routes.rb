Rails.application.routes.draw do
  require "sidekiq/web"
  Sidekiq::Web.use(AdminAuthMiddleware)
  mount Sidekiq::Web => "/sidekiq"

  PgHero::Engine.middleware.use(AdminAuthMiddleware)
  mount PgHero::Engine => "/pghero"
  mount ActionCable.server => "/cable"

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  namespace :onboarding do
    resources :emulator_profiles, only: [:index]
    resources :games, only: %i[index create destroy]
    resource :scan, only: [:create], controller: "scans"
    resource :completion, only: [:create]
  end

  resource :session
  resource :registration, only: %i[new create]
  resource :settings, only: %i[show update] do
    resource :password, only: [:update], controller: "settings/passwords"
  end
  resource :current_game, only: %i[update destroy], controller: "current_game"

  resource :game_scan, only: [:create], controller: "games/scans" do
    resource :confirmation, only: [:create], controller: "games/scans/confirmations"
  end
  resources :scan_paths, only: %i[create update destroy], controller: "games/paths", as: :scan_paths do
    collection do
      resource :browser, only: [:show], controller: "games/paths/browser", as: :directory_browser
    end
  end

  resources :data_exports, only: %i[create]
  resources :data_imports, only: %i[create] do
    resource :review, only: [:show], controller: "data_imports/reviews"
    resource :resolution, only: [:create], controller: "data_imports/resolutions"
  end

  resources :games do
    resource :emulator_configs, only: [:update], controller: "game_emulator_configs"
    resources :game_saves, only: %i[create destroy] do
      resource :download, only: [:show], controller: "game_saves/downloads"
    end
  end

  resource :activity, only: [:show], controller: "activity"

  resources :emulator_profiles, only: %i[index new create edit update destroy]
  scope :emulator_profiles, as: :emulator_profiles, module: :emulator_profiles do
    resources :library, only: %i[index show create]
    resource :bulk_destroy, only: [:create]
  end

  resources :notifications, only: %i[index show] do
    collection do
      resource :read_mark, only: [:create], controller: "notifications/read_marks"
    end
  end

  resources :web_push_subscriptions, only: %i[create destroy]
end
