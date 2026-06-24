Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users
  resources :topic_assignments, only: %i[index show new create edit update destroy] do
    collection do
      get :submission_status
    end
  end
  resources :haikus do
    collection do
      get :mine
      get :pending_review
    end
    resources :reviews, only: %i[create edit update destroy]
    resource :kigo_explanation, only: %i[show destroy]
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
