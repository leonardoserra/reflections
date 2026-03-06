Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # auth
  resource :session
  resources :passwords, param: :token
  resources :registrations, only: [ :new, :create ]

  # journals
  get "/journals", to: "journals#index"
  post "/journals", to: "journals#create"

  # books
  get "/books", to: "books#index"
  post "/books", to: "books#create"

  # reflections
  get "/reflection", to: "reflection#index"
  post "/reflection", to: "reflection#create"

  # healtcheck
  get "/up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
