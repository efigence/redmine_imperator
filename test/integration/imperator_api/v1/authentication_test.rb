require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class AuthenticationTest < Redmine::ApiTest::Base
      fixtures :users

      def test_api_should_deny_without_credentials
        get '/imperator_api/v1/users/current.json', {}
        assert_response 401
        assert_equal 'application/json', @response.content_type
        assert_equal User.anonymous, User.current
        # assert response.headers.key?('WWW-Authenticate')
        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_equal 'Invalid X-Imperator-API-Key', json['errors']
      end

      def test_api_should_accept_http_basic_auth_using_username_and_password
        user = User.generate! do |user|
          user.password = 'my_password'
        end
        get '/imperator_api/v1/users/current.json', {}, credentials(user.login, 'my_password')
        assert_response 200
        assert_equal 'application/json', @response.content_type
        assert_equal user, User.current
      end

      def test_api_should_deny_http_basic_auth_using_username_and_wrong_password
        user = User.generate! do |user|
          user.password = 'my_password'
        end
        get '/imperator_api/v1/users/current.json', {}, credentials(user.login, 'wrong_password')
        assert_response 401
        assert_equal 'application/json', @response.content_type
        assert_equal User.anonymous, User.current
      end

      def test_api_should_accept_http_basic_auth_using_api_key
        user = User.generate!
        token = Token.create!(user: user, action: 'api')
        get '/imperator_api/v1/users/current.json', {}, credentials(token.value, 'X')
        assert_response 200
        assert_equal 'application/json', @response.content_type
        assert_equal user, User.current
      end

      def test_api_should_deny_http_basic_auth_using_wrong_api_key
        user = User.generate!
        token = Token.create!(user: user, action: 'feeds') # not the API key
        get '/imperator_api/v1/users/current.json', {}, credentials(token.value, 'X')
        assert_response 401
        assert_equal 'application/json', @response.content_type
        assert_equal User.anonymous, User.current
      end

      def test_api_should_accept_auth_using_api_key_as_parameter
        user = User.generate!
        token = Token.create!(user: user, action: 'api')
        get "/imperator_api/v1/users/current.json?key=#{token.value}", {}, imperator_api_auth_headers
        assert_response 200
        assert_equal 'application/json', @response.content_type
        assert_equal user, User.current
      end

      def test_api_should_deny_auth_using_wrong_api_key_as_parameter
        user = User.generate!
        token = Token.create!(user: user, action: 'feeds') # not the API key
        get "/imperator_api/v1/users/current.json?key=#{token.value}", {}
        assert_response 401
        assert_equal 'application/json', @response.content_type
        assert_equal User.anonymous, User.current
      end

      def test_api_should_accept_auth_using_api_key_as_request_header
        user = User.generate!
        token = Token.create!(user: user, action: 'api')
        get '/imperator_api/v1/users/current.json', {},
                                                      'X-Redmine-API-Key' => token.value.to_s,
                                                      'X-Imperator-API-Key' => ::ImperatorApi::Key.new.show_secret
        assert_response 200
        assert_equal 'application/json', @response.content_type
        assert_equal user, User.current
      end

      def test_api_should_deny_auth_using_wrong_api_key_as_request_header
        user = User.generate!
        token = Token.create!(user: user, action: 'feeds') # not the API key
        get '/imperator_api/v1/users/current.json', {},
                                                      'X-Redmine-API-Key' => token.value.to_s,
                                                      'X-Imperator-API-Key' => ::ImperatorApi::Key.new.show_secret
        assert_response 401
        assert_equal 'application/json', @response.content_type
        assert_equal User.anonymous, User.current
      end

      def test_api_should_trigger_basic_http_auth_with_basic_authorization_header
        ApplicationController.any_instance.expects(:authenticate_with_http_basic).once
        get '/imperator_api/v1/users/current.json', {}, credentials('jsmith')
        assert_response 401
        assert_equal 'application/json', @response.content_type
      end

      def test_api_should_not_trigger_basic_http_auth_with_non_basic_authorization_header
        ApplicationController.any_instance.expects(:authenticate_with_http_basic).never
        get '/imperator_api/v1/users/current.json', {}, 'HTTP_AUTHORIZATION' => 'Digest foo bar'
        assert_response 401
        assert_equal 'application/json', @response.content_type
      end

      def test_invalid_utf8_credentials_should_not_trigger_an_error
        invalid_utf8 = "\x82".force_encoding('UTF-8')
        assert !invalid_utf8.valid_encoding?
        assert_nothing_raised do
          get '/imperator_api/v1/users/current.json', {}, credentials(invalid_utf8, 'foo')
        end
        assert_equal 'application/json', @response.content_type
      end

      def test_api_should_accept_switch_user_header_for_admin_user
        user = User.find(1)
        su = User.find(4)

        get '/imperator_api/v1/users/current.json', {}, 'X-Redmine-API-Key' => user.api_key,
                                                   'X-Redmine-Switch-User' => su.login,
                                                   'X-Imperator-API-Key' => ::ImperatorApi::Key.new.show_secret
        assert_response :success
        assert_equal 'application/json', @response.content_type
        assert_equal su, assigns(:user)
        assert_equal su, User.current
      end

      def test_api_should_respond_with_412_when_trying_to_switch_to_a_invalid_user
        get '/imperator_api/v1/users/current.json', {}, 'X-Redmine-API-Key' => User.find(1).api_key,
                                                   'X-Redmine-Switch-User' => 'foobar',
                                                   'X-Imperator-API-Key' => ::ImperatorApi::Key.new.show_secret
        assert_response 412
        assert_equal 'application/json', @response.content_type
      end

      def test_api_should_respond_with_412_when_trying_to_switch_to_a_locked_user
        user = User.find(5)
        assert user.locked?

        get '/imperator_api/v1/users/current.json', {}, 'X-Redmine-API-Key' => User.find(1).api_key,
                                                   'X-Redmine-Switch-User' => user.login,
                                                   'X-Imperator-API-Key' => ::ImperatorApi::Key.new.show_secret
        assert_response 412
        assert_equal 'application/json', @response.content_type
      end

      def test_api_should_not_accept_switch_user_header_for_non_admin_user
        user = User.find(2)
        su = User.find(4)

        get '/imperator_api/v1/users/current.json', {}, 'X-Redmine-API-Key' => user.api_key,
                                                   'X-Redmine-Switch-User' => su.login,
                                                   'X-Imperator-API-Key' => ::ImperatorApi::Key.new.show_secret
        assert_response :success
        assert_equal 'application/json', @response.content_type
        assert_equal user, assigns(:user)
        assert_equal user, User.current
      end
    end
  end
end
