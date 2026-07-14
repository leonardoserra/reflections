Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # auth
  resource :session
  resources :passwords, param: :token
  resources :registrations, only: [ :new, :create ]

  # pages
  resources :pages, only: [ :update, :create ]

  # journals
  resources :journals, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # books
  resources :books, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # reflections
  resources :reflections, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # bulk document operations
  resources :documents, only: [] do
    collection do
      post :bulk_destroy
    end
  end

  # healtcheck
  get "/up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
