# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
#ENV["BUNDLE_GEMFILE"] ||= File.exists?(fn = File.expand_path("../../Gemlocal", __FILE__)) ? fn : File.expand_path("../../Gemfile", __FILE__)

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
#require 'rails/all'
require 'codeclimate-test-reporter'
require 'simplecov'
require 'coveralls'

# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter,
    Coveralls::SimpleCov::Formatter
]

SimpleCov.start
require 'minitest/autorun'
