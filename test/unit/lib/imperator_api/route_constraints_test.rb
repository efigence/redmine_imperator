require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  class RouteConstraintsTest < ActiveSupport::TestCase
    def test_initialize
      subject = ImperatorApi::RouteConstraints.new(version: 2, default: true)
      assert_equal 2, subject.instance_variable_get(:@version)
      assert_equal true, subject.instance_variable_get(:@default)
    end

    def test_matches_match
      subject = ImperatorApi::RouteConstraints.new(version: 2, default: true)
      req = ActionController::TestRequest.new(host: 'example.com')
      assert subject.matches?(req)
    end

    def test_matches_no_match
      subject = ImperatorApi::RouteConstraints.new(version: 2)
      req = ActionController::TestRequest.new(host: 'example.com')
      refute subject.matches?(req)
    end
  end
end
