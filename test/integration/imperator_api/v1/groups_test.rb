require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class GroupsTest < Redmine::ApiTest::Base
      fixtures :users, :groups_users, :email_addresses

      test 'GET /imperator_api/v1/groups.json?builtin=1 should return all groups' do
        get '/imperator_api/v1/groups.json?builtin=1', {}, credentials('admin')
        assert_response :success
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['groups']
        assert_not_nil json['groups']
      end

      test 'GET /imperator_api/v1/groups.json should require authentication' do
        get '/imperator_api/v1/groups.json'
        assert_response 401
      end

      test 'GET /imperator_api/v1/groups.json should return groups' do
        get '/imperator_api/v1/groups.json', {}, credentials('admin')
        assert_response :success
        assert_equal 'application/json', response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        groups = json['groups']
        assert_kind_of Array, groups
        group = groups.detect { |g| g['name'] == 'A Team' }
        assert_not_nil group
        assert_equal({ 'id' => 10, 'name' => 'A Team' }, group)
      end

      test 'GET /imperator_api/v1/groups/:id.json should return the group' do
        get '/imperator_api/v1/groups/10.json', {}, credentials('admin')
        assert_response :success
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal 10, json['group']['id']
        assert_equal 'A Team', json['group']['name']
      end

      test 'GET /imperator_api/v1/groups/:id.json should return the builtin group' do
        get '/imperator_api/v1/groups/12.json', {}, credentials('admin')
        assert_response :success
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal 12, json['group']['id']
        assert_equal 'non_member', json['group']['builtin']
      end

      test 'GET /imperator_api/v1/groups/:id.json should include users if requested' do
        get '/imperator_api/v1/groups/10.json?include=users', {}, credentials('admin')
        assert_response :success
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['group']['users']
        assert_equal 8, json['group']['users'].first.try(:[], 'id')
        assert_equal 'User Misc', json['group']['users'].first.try(:[], 'name')
      end

      test 'GET /imperator_api/v1/groups/:id.json include memberships if requested' do
        get '/imperator_api/v1/groups/10.json?include=memberships', {}, credentials('admin')
        assert_response :success
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['group']['memberships']
      end

      test 'POST /imperator_api/v1/groups.json with valid parameters should create the group' do
        assert_difference('Group.count') do
          post '/imperator_api/v1/groups.json', { group: { name: 'Test', user_ids: [2, 3] } }, credentials('admin')
          assert_response :created
          assert_equal 'application/json', response.content_type
        end

        group = Group.order('id DESC').first
        assert_equal 'Test', group.name
        assert_equal [2, 3], group.users.map(&:id).sort

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal 'Test', json['group']['name']
      end

      test 'POST /imperator_api/v1/groups.json with invalid parameters should return errors' do
        assert_no_difference('Group.count') do
          post '/imperator_api/v1/groups.json', { group: { name: '' } }, credentials('admin')
        end
        assert_response :unprocessable_entity
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal 'Name cannot be blank', json['errors'].first
      end

      test 'PUT /imperator_api/v1/groups/:id.json with valid parameters should update the group' do
        group = Group.generate!
        put "/imperator_api/v1/groups/#{group.id}.json", { group: { name: 'New name', user_ids: [2, 3] } }, credentials('admin')
        assert_response :success
        assert_equal 'application/json', response.content_type
        assert_equal '', response.body

        assert_equal 'New name', group.reload.name
        assert_equal [2, 3], group.users.map(&:id).sort
      end

      test 'PUT /imperator_api/v1/groups/:id.json with invalid parameters should return errors' do
        group = Group.generate!
        put "/imperator_api/v1/groups/#{group.id}.json", { group: { name: '' } }, credentials('admin')
        assert_response :unprocessable_entity
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal 'Name cannot be blank', json['errors'].first
      end

      test 'DELETE /imperator_api/v1/groups/:id.json should delete the group' do
        group = Group.generate!
        assert_difference 'Group.count', -1 do
          delete "/imperator_api/v1/groups/#{group.id}.json", {}, credentials('admin')
          assert_response :success
          assert_equal '', response.body
        end
      end

      test 'POST /imperator_api/v1/groups/:id/users.json should add user to the group' do
        group = Group.generate!
        assert_difference 'group.reload.users.count' do
          post "/imperator_api/v1/groups/#{group.id}/users.json", { user_id: 5 }, credentials('admin')
          assert_response :success
          assert_equal '', @response.body
        end
        assert_include User.find(5), group.reload.users
      end

      test 'POST /imperator_api/v1/groups/:id/users.json should not add the user if already added' do
        group = Group.generate!
        group.users << User.find(5)

        assert_no_difference 'group.reload.users.count' do
          post "/imperator_api/v1/groups/#{group.id}/users.json", { user_id: 5 }, credentials('admin')
          assert_response :unprocessable_entity
        end

        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal 'User is invalid', json['errors'].first
      end

      test 'DELETE /imperator_api/v1/groups/:id/users/:user_id.json should remove user from the group' do
        group = Group.generate!
        group.users << User.find(8)

        assert_difference 'group.reload.users.count', -1 do
          delete "/imperator_api/v1/groups/#{group.id}/users/8.json", {}, credentials('admin')

          assert_response :success
          assert_equal '', @response.body
        end
        assert_not_include User.find(8), group.reload.users
      end
    end
  end
end
