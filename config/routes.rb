Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  post '/guest_login', to: 'guests#create', as: :guest_login
  post '/guest_admin_login', to: 'guests#create_admin', as: :guest_admin_login

  resources :password_resets, only: %i[new create edit update]

  resources :users
  resources :topic_assignments, only: %i[index show create update destroy] do
    collection do
      get :submission_status
      post :publish_all
    end
  end
  resources :haikus do
    collection do
      get :mine
      get :pending_review
    end
    resources :reviews, only: %i[create update destroy]
    resource :kigo_explanation, only: %i[show destroy]
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
