MailmanExampleCode::Application.routes.draw do
# Rails.application.routes.draw do

  root :to => 'settings_emails#index'

  resources :settings_emails

  resources :messages
  get 'messages/inbox/:id' => 'messages#index'
  get 'messages/view_html/:id' => 'messages#view_html'
  post 'messages/send_email' => 'messages#send_email'
  post 'testing/test_connection' => 'messages#test_connection'
  post 'messages/upload' => 'messages#add_attachment'

  match 'messages/inbox/:id', to: 'messages#index', via: [:options, :get]
  match 'messages/view_html/:id', to: 'messages#view_html', via: [:options, :get]
  match 'messages/unread/:id', to: 'messages#unread', via: [:options, :get]
  match 'settings_emails/:id', to: 'settings_emails#show', via: [:options, :get]
  match 'settings_email', to: 'settings_emails#create', via: [:options, :post]
  match 'settings_email/:id', to: 'settings_emails#update', via: [:options, :put]


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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
