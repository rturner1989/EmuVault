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
    resources :game_saves, only: %i[create destroy] do
      member do
        get :download
      end
    end
  end
  resource :activity, only: [:show], controller: "activity"
  resources :emulator_profiles

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
  mount ActionCable.server => "/cable"

  get "up" => "rails/health#show", as: :rails_health_check
end
