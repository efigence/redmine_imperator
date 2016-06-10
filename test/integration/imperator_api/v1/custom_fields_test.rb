require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class CustomFieldsTest < Redmine::ApiTest::Base
      fixtures :users, :custom_fields

      test 'GET /imperator_api/v1/custom_fields.json should return custom fields' do
        get '/imperator_api/v1/custom_fields.json', {}, credentials('admin')

        assert_response :success
        assert_equal 'application/json', response.content_type
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['custom_fields']
        assert_equal 1, json['custom_fields'].first.try(:[], 'id')
        assert_equal 'Database', json['custom_fields'].first.try(:[], 'name')
        assert_equal 2, json['custom_fields'].second.try(:[], 'id')
        assert_equal 'Searchable field', json['custom_fields'].second.try(:[], 'name')
      end
    end
  end
end
