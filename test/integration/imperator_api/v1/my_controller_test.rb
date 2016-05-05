require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class MyTest < Redmine::ApiTest::Base
      test "GET /imperator_api/v1/my/account.json should return: 418 - I\'m a teapot" do
        get '/imperator_api/v1/my/account.json', {}, credentials('admin')

        assert_response 418
        assert_equal 'application/json', response.content_type
      end
      test "GET /imperator_api/v1/my/page.json should return: 418 - I\'m a teapot" do
        get '/imperator_api/v1/my/page.json', {}, credentials('admin')

        assert_response 418
        assert_equal 'application/json', response.content_type
      end
    end
  end
end
