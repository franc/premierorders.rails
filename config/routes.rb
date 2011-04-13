PgRails::Application.routes.draw do
  resources :production_batches do
    member do
      get 'cutrite'
      get 'download'
    end
  end
 
  resources :job_items do
    member do
      get 'compute_unit_price'
    end
  end

  resources :franchisee_addresses

  devise_for :users

  match 'items/search' => 'items#search'
  match 'items/sort'                            => 'items#sort'
  match 'items/sorting'                         => 'items#sorting'
  match 'items/add_property_form'               => 'items#add_property_form'
  match 'items/add_component_form'              => 'items#add_component_form'
  match 'items/:mod/property_descriptors'       => 'items#property_descriptors'
  match 'items/:mod/component_descriptors'      => 'items#component_descriptors'
  match 'items/:mod/component_association_types' => 'items#component_association_types'
  match 'items/:mod/property_form_fragment/:id' => 'items#property_form_fragment'
  match 'items/add_property'                    => 'items#add_property'
  resources :items do
    member do
      post 'dup'
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
  resources :properties do
    resources :property_values
  end

  match 'jobs/dashboard' => 'jobs#dashboard'
  resources :jobs do
    member do
      get 'cutrite'
      get 'download'
      get 'recalculate'
      post 'place_order'
    end
  end

  match 'catalog_orders/catalog_json' => 'catalog_orders#catalog_json'
  match 'catalog_orders/reference_data' => 'catalog_orders#reference_data'
  match 'catalog_orders/:id/add_item' => 'catalog_orders#update_item'
  resources :catalog_orders

  resources :franchisees do
    member do
      get 'addresses'
      post 'create_address'
    end
  end

  resources :users

  resources :addresses

  match 'reports/:action', :controller => 'reports'
  match '/cache.manifest' => 'application#manifest'
  match '/offline.html' => 'application#offline'
  match '/ping' => 'application#ping'

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
end
