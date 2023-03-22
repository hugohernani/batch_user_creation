require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => 'sidekiq'

  root 'batch/users#index'

  post 'batch/users', to: 'batch/users#create', as: :users_batch
end
