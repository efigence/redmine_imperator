require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class RolesTest < Redmine::ApiTest::Base
      fixtures :roles

      test 'GET /imperator_api/v1/roles.json should return the roles' do
        get '/imperator_api/v1/roles.json', {}, imperator_api_auth_headers

        assert_response :success
        assert_equal 'application/json', @response.content_type
        assert_equal 3, assigns(:roles).size

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['roles']
        assert_include({ id: 2, name: 'Developer' }.stringify_keys, json['roles'])
      end

      test 'GET /imperator_api/v1/roles/:id.json should return the role' do
        get '/imperator_api/v1/roles/1.json', {}, imperator_api_auth_headers

        assert_response :success
        assert_equal 'application/json', @response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Hash, json['role']
        assert_equal 1, json['role']['id']
        assert_equal 'Manager', json['role']['name']
        assert_include 'view_issues', json['role']['permissions']
      end

      # actions not supported by Redmine API yet:

      test 'POST /imperator_api/v1/roles.json with valid parameters should create the role' do
        skip
        assert_difference('Role.count') do
          post '/imperator_api/v1/roles.json', {
            permissions: Role.non_member.permissions
          }, credentials('admin')
        end

        role = Role.order('id DESC').first
        assert_equal 123, role.user_id

        assert_response :created
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Hash, json['role']
        assert_equal user.id, json['role']['id']
      end

      test 'POST /imperator_api/v1/roles.json with with invalid parameters should return errors' do
        skip
        assert_no_difference('Role.count') do
          post '/imperator_api/v1/roles.json', { foo: 'bar' }, credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert json.key?('errors')
        assert_kind_of Array, json['errors']
      end

      test 'PUT /imperator_api/v1/roles/:id.json with valid parameters should update the role' do
        skip
        assert_no_difference('Role.count') do
          put '/imperator_api/v1/roles/2.json', {
            permissions: Role.non_member.permissions
          }, credentials('admin')
        end

        role = Role.find(2)
        assert_equal({}, role.permissions)

        assert_response :ok
        assert_equal '', @response.body
      end

      test 'PUT /imperator_api/v1/roles/:id.json with invalid parameters' do
        skip
        assert_no_difference('Role.count') do
          put '/imperator_api/v1/roles/2.json', {
            permissions: Role.non_member.permissions
          }, credentials('admin')
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
