Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  resources :subjects
  resources :destinations

  resources :expedients do
    member do
      put :treat
      put :delete_from_agenda
    end
  end

  resources :daily_agendas do
    member do
      get :add_expedients # muestra el modal con la lista
      post :attach_expedient # agrega uno
      put :resolve
    end
    collection do
      get :today
    end
  end
end
