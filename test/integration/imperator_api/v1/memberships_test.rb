require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# FIXME: change xml tests to json
module ImperatorApi
  module V1
    class MembershipsTest < Redmine::ApiTest::Base
      fixtures :projects, :users, :roles, :members, :member_roles

      test 'GET /imperator_api/v1/projects/:project_id/memberships.json should return memberships' do
        get '/imperator_api/v1/projects/1/memberships.json', {}, credentials('jsmith')

        assert_response :success
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_equal({
                       'memberships' =>
                         [{ 'id' => 1,
                            'project' => { 'name' => 'eCookbook', 'id' => 1 },
                            'roles' => [{ 'name' => 'Manager', 'id' => 1 }],
                            'user' => { 'name' => 'John Smith', 'id' => 2 } },
                          { 'id' => 2,
                            'project' => { 'name' => 'eCookbook', 'id' => 1 },
                            'roles' => [{ 'name' => 'Developer', 'id' => 2 }],
                            'user' => { 'name' => 'Dave Lopper', 'id' => 3 } }],
                       'limit' => 25,
                       'total_count' => 2,
                       'offset' => 0 },
                     json)
      end

      test 'GET /imperator_api/v1/projects/:project_id/memberships.xml should succeed for closed project' do
        project = Project.find(1)
        project.close
        assert !project.reload.active?
        get '/imperator_api/v1/projects/1/memberships.json', {}, credentials('jsmith')
        assert_response :success
      end

      test 'POST /imperator_api/v1/projects/:project_id/memberships.xml should create the membership' do
        assert_difference 'Member.count' do
          post '/imperator_api/v1/projects/1/memberships.xml', { membership: { user_id: 7, role_ids: [2, 3] } }, credentials('jsmith')

          assert_response :created
        end
      end

      test 'POST /imperator_api/v1/projects/:project_id/memberships.xml should create the group membership' do
        group = Group.find(11)

        assert_difference 'Member.count', 1 + group.users.count do
          post '/imperator_api/v1/projects/1/memberships.xml', { membership: { user_id: 11, role_ids: [2, 3] } }, credentials('jsmith')

          assert_response :created
        end
      end

      test 'POST /imperator_api/v1/projects/:project_id/memberships.xml with invalid parameters should return errors' do
        assert_no_difference 'Member.count' do
          post '/imperator_api/v1/projects/1/memberships.xml', { membership: { role_ids: [2, 3] } }, credentials('jsmith')

          assert_response :unprocessable_entity
          assert_equal 'application/xml', @response.content_type
          assert_select 'errors error', text: 'Principal cannot be blank'
        end
      end

      test 'GET /imperator_api/v1/memberships/:id.json should return the membership' do
        get '/imperator_api/v1/memberships/2.json', {}, credentials('jsmith')

        assert_response :success
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_equal(
          { 'membership' => {
            'id' => 2,
            'project' => { 'name' => 'eCookbook', 'id' => 1 },
            'roles' => [{ 'name' => 'Developer', 'id' => 2 }],
            'user' => { 'name' => 'Dave Lopper', 'id' => 3 } }
          },
          json)
      end

      test 'PUT /imperator_api/v1/memberships/:id.xml should update the membership' do
        assert_not_equal [1, 2], Member.find(2).role_ids.sort
        assert_no_difference 'Member.count' do
          put '/imperator_api/v1/memberships/2.xml', { membership: { user_id: 3, role_ids: [1, 2] } }, credentials('jsmith')

          assert_response :ok
          assert_equal '', @response.body
        end
        member = Member.find(2)
        assert_equal [1, 2], member.role_ids.sort
      end

      test 'PUT /imperator_api/v1/memberships/:id.xml with invalid parameters should return errors' do
        put '/imperator_api/v1/memberships/2.xml', { membership: { user_id: 3, role_ids: [99] } }, credentials('jsmith')

        assert_response :unprocessable_entity
        assert_equal 'application/xml', @response.content_type
        assert_select 'errors error', text: 'Role cannot be empty'
      end

      test 'DELETE /imperator_api/v1/memberships/:id.xml should destroy the membership' do
        assert_difference 'Member.count', -1 do
          delete '/imperator_api/v1/memberships/2.xml', {}, credentials('jsmith')

          assert_response :ok
          assert_equal '', @response.body
        end
        assert_nil Member.find_by_id(2)
      end

      test 'DELETE /imperator_api/v1/memberships/:id.xml should respond with 422 on failure' do
        assert_no_difference 'Member.count' do
          # A membership with an inherited role cannot be deleted
          Member.find(2).member_roles.first.update_attribute :inherited_from, 99
          delete '/imperator_api/v1/memberships/2.xml', {}, credentials('jsmith')

          assert_response :unprocessable_entity
        end
      end
    end
  end
end
