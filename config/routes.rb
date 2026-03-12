Rails.application.routes.draw do
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'

  get "up" => "rails/health#show", as: :rails_health_check
end
