Rails.application.routes.draw do
  resources :notifications

  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  use_doorkeeper do
    controllers :applications => 'oauth/applications'
  end
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  get 'users/login/:id', to: 'users#dev_login'
  match 'users/new', to: 'users#new', via: [:get]
  match 'users/new', to: 'users#new_update', via: [:patch, :put]
  resources :users, :only => [:index, :show, :update]
  devise_scope :user do
    get '/logout' => "devise/sessions#destroy"
  end

  match '/me', to: 'me#dashboard', via: [:get]
  match '/dashboard', to: 'me#dashboard', via: [:get]
  match '/data', to: 'me#data', via: [:get]
  match '/data', to: 'me#data_update', via: [:post, :put, :patch]
  match '/notifications', to: 'me#notifications', via: [:get]
  match '/friends', to: 'me#friends', via: [:get]
  match '/settings', to: 'me#settings', via: [:get]
  match '/settings', to: 'me#settings_update', via: [:post, :put, :patch]

  get '/api-docs.json' => "pages#api_docs_json"
  get '/api-docs/api/:v/:name' => "pages#api_doc_json"
  get '/api' => "pages#api_docs"

  root "me#dashboard"

  namespace :api do
    namespace :v1 do
      get '/me' => "oauth_api#me"
      post '/me' => "oauth_api#me"
      post '/me/send_notification' => "oauth_api#send_notification"
      post '/me/send_sms' => "oauth_api#send_sms"
      get '/user/:id' => "user_api#user_data"
      post '/user/:id' => "user_api#user_data"
      post '/user/:id/send_notification' => "user_api#send_notification"
      post '/user/:id/send_sms' => "user_api#send_sms"
      get '/rfid_scan/:id' => "user_api#rfid_scan"
      get '/admission_year/:admission_year/department/:department_code/users' => "user_api#list_users"
      get '/find_user' => "user_api#find_user"
      post '/find_user' => "user_api#find_user"
      get '/colleges' => "data_api#colleges"
      get '/departments' => "data_api#departments"
      get '/site_data' => "data_api#site_data"
      get '/site_navigation' => "data_api#site_navigation"
      get '/site_menu' => "data_api#site_menu"
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
