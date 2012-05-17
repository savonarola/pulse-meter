require 'rubygems'
require 'bundler/setup'
$:.unshift File.expand_path('../../lib/', __FILE__)

ROOT = File.expand_path('../..', __FILE__)

require 'pulse-meter'
require 'pulse-meter/visualizer'
require 'test_helpers/matchers'
require 'rack/test'

Bundler.require(:default, :test, :development)

Dir['spec/support/**/*.rb'].each{|f| require File.join(ROOT, f) }
Dir['spec/shared_examples/**/*.rb'].each{|f| require File.join(ROOT,f)}
Dir['spec/shared_context/**/*.rb'].each{|f| require File.join(ROOT,f)}

RSpec.configure do |config|
  config.before(:each) { PulseMeter.redis = MockRedis.new }
  PulseMeter::Client::Manager.redis_class = MockRedis

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.include(TestHelpers::Matchers)
end

