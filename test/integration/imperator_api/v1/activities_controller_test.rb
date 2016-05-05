require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class ActivitiesTest < Redmine::ApiTest::Base
      test "GET /imperator_api/v1/activity.json should return: 418 - I\'m a teapot" do
        get '/imperator_api/v1/activity.json', {}, credentials('admin')

        assert_response 418
        assert_equal 'application/json', response.content_type
      end
    end
  end
end
