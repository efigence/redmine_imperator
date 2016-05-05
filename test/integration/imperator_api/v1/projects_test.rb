require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class ProjectsTest < Redmine::ApiTest::Base
      fixtures :projects, :versions, :users, :roles, :members, :member_roles,
               :issues, :journals, :journal_details, :trackers, :projects_trackers,
               :issue_statuses, :enabled_modules, :enumerations, :boards, :messages,
               :attachments, :custom_fields, :custom_values, :time_entries, :issue_categories

      def setup
        super
        set_tmp_attachments_directory
      end

      test 'GET /imperator_api/v1/projects.json should return projects' do
        get '/imperator_api/v1/projects.json', credentials('admin')
        assert_response :success
        assert_equal 'application/json', @response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Array, json['projects']
        assert_kind_of Hash, json['projects'].first
        assert json['projects'].first.key?('id')
        assert_equal 1, json['projects'].first.try(:[], 'id')
        assert_equal 1, json['projects'].first.try(:[], 'status')
        assert_equal true, json['projects'].first.try(:[], 'is_public')
      end

      test 'GET /imperator_api/v1/projects.json should return pagination meta' do
        get '/imperator_api/v1/projects.json', credentials('admin')
        assert_response :success
        assert_equal 'application/json', @response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert json.key?('total_count')
        assert json.key?('offset')
        assert json.key?('limit')
      end

      test 'GET /imperator_api/v1/projects/:id.json should return the project' do
        get '/imperator_api/v1/projects/1.json', credentials('admin')
        assert_response :success
        assert_equal 'application/json', @response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Hash, json['project']
        assert_equal 1, json['project']['id']
      end

      test 'GET /imperator_api/v1/projects/:id.json with hidden custom \
        fields should not display hidden custom fields' do
        ProjectCustomField.find_by_name('Development status').update_attribute :visible, false

        get '/imperator_api/v1/projects/1.json', credentials('admin')
        assert_response :success
        assert_equal 'application/json', @response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Hash, json['project']
        assert_equal 1, json['project']['id']
        assert_nil json['project']['custom_fields']
      end

      test 'GET /imperator_api/v1/projects.json with include=issue_categories should return categories' do
        get '/imperator_api/v1/projects.json?include=issue_categories', credentials('admin')
        assert_response :success
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['projects']
        assert_kind_of Hash, json['projects'].first
        assert json['projects'].first.key?('issue_categories')
        assert_kind_of Array, json['projects'].first['issue_categories']
        assert_includes(json['projects'].first['issue_categories'],
                        { id: 2, name: 'Recipes' }.stringify_keys)
      end

      test 'GET /imperator_api/v1/projects.json with include=trackers should return trackers' do
        skip
        get '/imperator_api/v1/projects.json?include=trackers', credentials('admin')

        assert_response :success
        assert_equal 'application/json', @response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['projects']
        assert_kind_of Hash, json['projects'].first
        assert json['projects'].first.key?('trackers')
        assert_kind_of Array, json['projects'].first['trackers']
        associations = json['projects'].first['trackers']
                       .select do |k, v|
                         k.to_s == 'id' && v == '2'
                       end
        assert_equal 'Feature request', associations.first.try(:[], 'name')
      end

      test 'GET /imperator_api/v1/projects.json with include=enabled_modules should return enabled modules' do
        get '/imperator_api/v1/projects.json?include=enabled_modules', credentials('admin')
        assert_response :success
        assert_equal 'application/json', @response.content_type

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['projects']
        assert_kind_of Hash, json['projects'].first
        assert json['projects'].first.key?('enabled_modules')
        assert_kind_of Array, json['projects'].first['enabled_modules']
        associations = json['projects'].first['enabled_modules'].select { |k, _v| k['name'] == 'issue_tracking' }

        assert_not_empty associations
      end

      test 'POST /imperator_api/v1/projects.json with valid parameters should create the project' do
        with_settings default_projects_modules: %w(issue_tracking repository) do
          assert_difference('Project.count') do
            post '/imperator_api/v1/projects.json',
                 { project: { name: 'API test', identifier: 'api-test' } },
                 credentials('admin')
          end
        end

        project = Project.order('id DESC').first
        assert_equal 'API test', project.name
        assert_equal 'api-test', project.identifier
        assert_equal %w(issue_tracking repository), project.enabled_module_names.sort
        assert_equal Tracker.all.size, project.trackers.size

        assert_response :created
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Hash, json['project']
        assert_equal project.id, json['project']['id']
      end

      test 'POST /imperator_api/v1/projects.json should accept enabled_module_names attribute' do
        assert_difference('Project.count') do
          post '/imperator_api/v1/projects.json', {
            project: {
              name: 'API test', identifier: 'api-test',
              enabled_module_names: %w(issue_tracking news time_tracking)
            }
          }, credentials('admin')
        end

        project = Project.order('id DESC').first
        assert_equal %w(issue_tracking news time_tracking), project.enabled_module_names.sort
      end

      test 'POST /imperator_api/v1/projects.json should accept tracker_ids attribute' do
        assert_difference('Project.count') do
          post '/imperator_api/v1/projects.json',
               { project: { name: 'API test', identifier: 'api-test', tracker_ids: [1, 3] } },
               credentials('admin')
        end

        project = Project.order('id DESC').first
        assert_equal [1, 3], project.trackers.map(&:id).sort
      end

      test 'POST /imperator_api/v1/projects.json with invalid parameters should return errors' do
        assert_no_difference('Project.count') do
          post '/imperator_api/v1/projects.json', { project: { name: 'API test' } }, credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert json.key?('errors')
        assert_kind_of Array, json['errors']
        assert_includes json['errors'], 'Identifier cannot be blank'
      end

      test 'PUT /imperator_api/v1/projects/:id.json with valid parameters should update the project' do
        assert_no_difference 'Project.count' do
          put '/imperator_api/v1/projects/2.json', { project: { name: 'API update' } }, credentials('jsmith')
        end
        assert_response :ok
        assert_equal '', @response.body
        assert_equal 'application/json', @response.content_type
        project = Project.find(2)
        assert_equal 'API update', project.name
      end

      test 'PUT /imperator_api/v1/projects/:id.json should accept enabled_module_names attribute' do
        assert_no_difference 'Project.count' do
          put '/imperator_api/v1/projects/2.json', {
            project: {
              name: 'API update',
              enabled_module_names: %w(issue_tracking news time_tracking)
            }
          }, credentials('admin')
        end

        assert_response :ok
        assert_equal '', @response.body
        project = Project.find(2)
        assert_equal %w(issue_tracking news time_tracking), project.enabled_module_names.sort
      end

      test 'PUT /imperator_api/v1/projects/:id.json should accept tracker_ids attribute' do
        assert_no_difference 'Project.count' do
          put '/imperator_api/v1/projects/2.json', {
            project: {
              name: 'API update',
              tracker_ids: [1, 3]
            }
          }, credentials('admin')
        end

        assert_response :ok
        assert_equal '', @response.body
        project = Project.find(2)
        assert_equal [1, 3], project.trackers.map(&:id).sort
      end

      test 'PUT /imperator_api/v1/projects/:id.json with invalid parameters should return errors' do
        assert_no_difference('Project.count') do
          put '/imperator_api/v1/projects/2.json', { project: { name: '' } }, credentials('admin')
        end

        assert_response :unprocessable_entity
        assert_equal 'application/json', @response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert json.key?('errors')
        assert_kind_of Array, json['errors']
        assert_includes json['errors'], 'Name cannot be blank'
      end

      test 'DELETE /imperator_api/v1/projects/:id.json should delete the project' do
        assert_difference('Project.count', -1) do
          delete '/imperator_api/v1/projects/2.json', {}, credentials('admin')
        end
        assert_response :ok
        assert_equal '', @response.body
        assert_nil Project.find_by_id(2)
      end
    end
  end
end
