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
        role_name = 'Example role'
        assert_difference('Role.count') do
          post '/imperator_api/v1/roles.json', {
            role: { name: role_name }
          }, credentials('admin')
        end

        role = Role.order('id DESC').first
        assert_equal role_name, role.name

        assert_response :created
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Hash, json['role']
        assert_equal role_name, json['role']['name']
      end

      test 'POST /imperator_api/v1/roles.json with with invalid parameters should return errors' do
        assert_no_difference('Role.count') do
          post '/imperator_api/v1/roles.json', { role: { name: '' } }, credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert json.key?('errors')
        assert_kind_of Array, json['errors']
      end

      test 'PUT /imperator_api/v1/roles/:id.json with valid parameters should update the role' do
        new_name = 'Edited role name'
        assert_no_difference('Role.count') do
          put '/imperator_api/v1/roles/2.json', {
            role: { name: new_name }
          }, credentials('admin')
        end

        role = Role.find(2)
        assert_equal(new_name, role.name)

        assert_response :ok
        assert_equal '', @response.body
      end

      test 'PUT /imperator_api/v1/roles/:id.json with invalid parameters' do
        assert_no_difference('Role.count') do
          put '/imperator_api/v1/roles/2.json', {
            role: { name: '' }
          }, credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert json.key?('errors')
        assert_kind_of Array, json['errors']
      end

      test 'DELETE /imperator_api/v1/roles/:id.json' do
        role = Role.find 3
        role.member_roles.destroy_all
        assert_difference('Role.count', -1) do
          delete '/imperator_api/v1/roles/3.json', {}, credentials('admin')
        end

        assert_response :ok
        assert_equal '', @response.body
      end
    end
  end
end
