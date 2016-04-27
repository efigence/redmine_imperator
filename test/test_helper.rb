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
