require 'imperator_api/route_constraints'

scope module: 'imperator_api', path: '/imperator_api' do
  scope module: :v1, path: '/v1', constraints: ::ImperatorApi::RouteConstraints.new(version: 1, default: true) do
    resources :groups do
      # resources :memberships, controller: 'principal_memberships'
      # member do
      #   get 'autocomplete_for_user'
      # end
    end
    # get 'groups/:id/users/new', to: 'groups#new_users', id: /\d+/ # , :as => 'new_group_users'
    post 'groups/:id/users', to: 'groups#add_users', id: /\d+/ # , :as => 'group_users'
    delete 'groups/:id/users/:user_id', to: 'groups#remove_user' # , :id => /\d+/, :as => 'group_user'

    resources :custom_fields, only: :index
    resources :projects do
      shallow do
        resources :memberships, controller: 'members', only: [:index, :show, :new, :create, :update, :destroy] do
          # collection do
          #   get 'autocomplete'
          # end
        end
      end
    end

    resources :roles
    resources :users

    # stubbed with status code 418 - actions only for authentication tests:
    resources :issues
    get 'search', controller: 'search', action: 'index'
    get 'activity', to: 'activities#index'
    match 'my/account', controller: 'my', action: 'account', via: [:get, :post]
    # match 'my/account/destroy', controller: 'my', action: 'destroy', via: [:get, :post]
    match 'my/page', controller: 'my', action: 'page', via: :get
    # match 'my', controller: 'my', action: 'index', via: :get # Redirects to my/page
    # get 'my/api_key', to: 'my#show_api_key', as: 'my_api_key'
    # post 'my/api_key', to: 'my#reset_api_key'
    # post 'my/rss_key', to: 'my#reset_rss_key', as: 'my_rss_key'
    # match 'my/password', controller: 'my', action: 'password', via: [:get, :post]
    # match 'my/page_layout', controller: 'my', action: 'page_layout', via: :get
    # match 'my/add_block', controller: 'my', action: 'add_block', via: :post
    # match 'my/remove_block', controller: 'my', action: 'remove_block', via: :post
    # match 'my/order_blocks', controller: 'my', action: 'order_blocks', via: :post
  end
  get '*path', to: 'v1/api#route_not_found'
end
