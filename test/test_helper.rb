if ENV['CI'] && ENV['TRAVIS']
  require '/home/travis/build/efigence/redmine_imperator/workspace/redmine/test/test_helper'
else
  require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
end
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'
require 'minitest/autorun'
begin
  require 'codeclimate-test-reporter'
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter,
      Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start
rescue NameError, LoadError
end

Redmine::IntegrationTest.class_eval do
  def imperator_api_auth_headers(headers = {})
    { 'HTTP_ACCEPT' => 'application/vnd.imperator_api+json; version=1',
      'HTTP_X_IMPERATOR_API_KEY' => ::ImperatorApi::Key.new.show_secret }.merge(headers)
  end

  def credentials(user, password = nil, auth_headers = {})
    imperator_api_auth_headers.merge('HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic
                                                            .encode_credentials(user, password || user))
                                                            .merge(auth_headers)
  end
end
