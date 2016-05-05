require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# FIXME: change xml to json
module ImperatorApi
  module V1
    class CustomFieldsTest < Redmine::ApiTest::Base
      fixtures :users, :custom_fields

      test 'GET /imperator_api/v1/custom_fields.xml should return custom fields' do
        get '/imperator_api/v1/custom_fields.xml', {}, credentials('admin')

        assert_response :success
        assert_equal 'application/xml', response.content_type

        assert_select 'custom_fields' do
          assert_select 'custom_field' do
            assert_select 'name', text: 'Database'
            assert_select 'id', text: '2'
            assert_select 'customized_type', text: 'issue'
            assert_select 'possible_values[type=array]' do
              assert_select 'possible_value>value', text: 'PostgreSQL'
            end
            assert_select 'trackers[type=array]'
            assert_select 'roles[type=array]'
          end
        end
      end
    end
  end
end
