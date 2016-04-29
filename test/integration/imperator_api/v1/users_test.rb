require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class UsersTest < Redmine::ApiTest::Base
      fixtures :users, :email_addresses, :members, :member_roles, :roles, :projects

      test 'GET /imperator_api/v1/users.json should return users' do
        get '/imperator_api/v1/users.json', {}, credentials('admin')

        assert_response :success
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert json.key?('users')
        assert_equal assigns(:users).size, json['users'].size
      end

      test 'GET /imperator_api/v1/users/:id.json should return the user' do
        get '/imperator_api/v1/users/2.json'

        assert_response :success
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Hash, json['user']
        assert_equal 2, json['user']['id']
      end

      test 'GET /users/:id.json with include=memberships should include memberships' do
        get '/users/2.json?include=memberships'

        assert_response :success
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Array, json['user']['memberships']
        assert_equal [{
          'id' => 1,
          'project' => { 'name' => 'eCookbook', 'id' => 1 },
          'roles' => [{ 'name' => 'Manager', 'id' => 1 }]
        }], json['user']['memberships']
      end

      test 'POST /users.json with valid parameters should create the user' do
        assert_difference('User.count') do
          post '/users.json', {
            user: {
              login: 'foo', firstname: 'Firstname', lastname: 'Lastname',
              mail: 'foo@example.net', password: 'secret123',
              mail_notification: 'only_assigned' }
          },
               credentials('admin')
        end

        user = User.order('id DESC').first
        assert_equal 'foo', user.login
        assert_equal 'Firstname', user.firstname
        assert_equal 'Lastname', user.lastname
        assert_equal 'foo@example.net', user.mail
        assert !user.admin?

        assert_response :created
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Hash, json['user']
        assert_equal user.id, json['user']['id']
      end

      test 'POST /users.json with with invalid parameters should return errors' do
        assert_no_difference('User.count') do
          post '/users.json', { user: { login: 'foo', lastname: 'Lastname', mail: 'foo' } }, credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert json.key?('errors')
        assert_kind_of Array, json['errors']
      end

      test 'PUT /users/:id.json with valid parameters should update the user' do
        assert_no_difference('User.count') do
          put '/users/2.json', {
            user: {
              login: 'jsmith', firstname: 'John', lastname: 'Renamed',
              mail: 'jsmith@somenet.foo' }
          },
              credentials('admin')
        end

        user = User.find(2)
        assert_equal 'jsmith', user.login
        assert_equal 'John', user.firstname
        assert_equal 'Renamed', user.lastname
        assert_equal 'jsmith@somenet.foo', user.mail
        assert !user.admin?

        assert_response :ok
        assert_equal '', @response.body
      end

      test 'PUT /users/:id.json with invalid parameters' do
        assert_no_difference('User.count') do
          put '/users/2.json', {
            user: {
              login: 'jsmith', firstname: '', lastname: 'Lastname',
              mail: 'foo' }
          },
              credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert json.key?('errors')
        assert_kind_of Array, json['errors']
      end
    end
  end
end
