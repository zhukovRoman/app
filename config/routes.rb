Rails.application.routes.draw do
  get 'info/index'

  get 'tenders/index'

  get 'api/getchart'


  get 'apartment/index'

  devise_for :users
  get 'object/index'
  get 'object/finance'
  get 'object/view'
  get 'object/overdue'
  get 'object/organizations'

  get 'employee/vacancies'
  post 'employee/vacancies'

  get 'welcome/index'

  get 'employee/personalflowXmlParse'
  get 'employee/pfxmlp'
  get 'employee/salaryXmlParse'
  get 'employee/personalInit'
  get 'employee/vacancies'
  get 'employee/index'

  get 'employee/editmanagment'
  post 'employee/editmanagment'

  get 'employee/calculate'
  get 'employee/salaryXMLChange'


  get 'apartment/index'
  get 'apartment/index2'
  get 'api/getchart'

  get 'apartment/crm'

  get 'object/index'


  get 'tenders/index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
