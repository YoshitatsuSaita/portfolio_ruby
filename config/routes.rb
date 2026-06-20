Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users

  get 'up' => 'rails/health#show', as: :rails_health_check
end
