PgRails::Application.routes.draw do
  resources :job_items

  resources :franchisee_addresses

  devise_for :users

  match 'items/search' => 'items#search'
  match 'items/add_property_form'               => 'items#add_property_form'
  match 'items/add_component_form'              => 'items#add_component_form'
  match 'items/:mod/property_descriptors'       => 'items#property_descriptors'
  match 'items/:mod/component_descriptors'      => 'items#component_descriptors'
  match 'items/:mod/component_association_types' => 'items#component_association_types'
  match 'items/:mod/property_form_fragment/:id' => 'items#property_form_fragment'
  match 'items/add_property'                    => 'items#add_property'
  resources :items do
    member do
      get 'properties'
      get 'components'
      post 'add_component'
      get 'pricing_expr'
    end
  end

  resources :item_properties

  match 'item_components/:mod/property_descriptors'       => 'item_components#property_descriptors'
  match 'item_components/:mod/property_form_fragment/:id' => 'item_components#property_form_fragment'
  match 'item_components/add_property_form'               => 'item_components#add_property_form'
  match 'item_components/add_property'                    => 'item_components#add_property'
  resources :item_components do
    member do
      get 'properties'
    end
  end

  resources :item_component_properties

  match 'properties/search' => 'properties#search'
  resources :properties 

  resources :jobs do
    member do
      get 'cutrite'
      get 'download'
      post 'place_order'
    end
  end

  resources :franchisees do
    member do
      get 'addresses'
      post 'create_address'
    end
  end

  resources :users

  resources :addresses

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "jobs#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
