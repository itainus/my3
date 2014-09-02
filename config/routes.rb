Rails.application.routes.draw do
  get 'user/tree'

  get 'home/index'

  devise_for :users

  root 'home#index'
  # get 'tree/index'
  # post "tree/category_create"

  get "home/tree" => "home#tree"
  get "home/friends" => "home#friends"
  post "home/tree" => "home#tree"

  get "tree/:id" => "tree#index"


  post "tree/:id/category_create" => "tree#create_new_category"
  post "tree/:id/category_add" => "tree#add_category"
  post "tree/:id/link_create" => "tree#create_new_link"
  post "tree/:id/link_add" => "tree#add_link"

  post "tree/:id/link_remove" => "tree#remove_link"
  post "tree/:id/link_update" => "tree#update_link"

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
