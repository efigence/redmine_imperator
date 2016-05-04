require 'imperator_api/route_constraints'

scope module: 'imperator_api', path: '/imperator_api' do
  scope module: :v1, path: '/v1', constraints: ::ImperatorApi::RouteConstraints.new(version: 1, default: true) do
    resources :projects
    resources :roles
    resources :users
  end
  get '*path', to: 'v1/api#route_not_found'
end
