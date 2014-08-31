IdentifiRails::Application.routes.draw do
  get "search/index"
  get "send/index"
  get "home/index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  get 'feed' => 'home#feed'
  get 'about' => 'home#about'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get 'login' => 'login#index'

  get 'search(/:query)' => 'search#index', :constraints => { :query => /[^\/]+/ }
  get 'id/:type/:value' => 'identifier#show', :constraints => { :type => /[^\/]+/, :value => /.+/ }
  get 'id/sent' => 'identifier#sent', :constraints => { :type => /[^\/]+/, :value => /.+/ }
  get 'id/received' => 'identifier#received', :constraints => { :type => /[^\/]+/, :value => /.+/ }
  post 'id/overview' => 'identifier#overview', :constraints => { :type => /[^\/]+/, :value => /.+/ }
  post 'id/getconnectingmsgs' => 'identifier#getconnectingmsgs', :constraints => { :id1type => /[^\/]+/, :id1value => /.+/ }
  post 'id/write' => 'identifier#write', :constraints => { :type => /[^\/]+/, :value => /.+/ }
  post 'id/confirm' => 'identifier#confirm', :constraints => { :type => /[^\/]+/, :value => /.+/ }
  post 'id/refute' => 'identifier#refute', :constraints => { :type => /[^\/]+/, :value => /.+/ }


  get 'message(/:hash)' => 'msg#show'

  match 'settings', to: 'sessions#settings', via: [:get, :post]
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'logout', to: 'sessions#destroy', as: 'logout', via: [:get, :post]

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
