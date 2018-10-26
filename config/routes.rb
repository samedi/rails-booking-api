# frozen_string_literal: true

Rails.application.routes.draw do
  resources :event_categories, only: %i[index]
  resources :event_types, only: %i[index]
  resources :event_dates, only: %i[index]
  resources :event_timeslots, only: %i[index]
  resources :bookings, only: %i[new create] do
    member do
      get :success
    end
  end

  get '/:provider/oauth/callback', to: 'sessions#create'
  post '/sign_out', to: 'sessions#destroy'
  get '/access_token', to: 'sessions#show_access_token' if Rails.env.development?

  root to: 'landing#show'
end
