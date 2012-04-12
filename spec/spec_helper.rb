require 'rubygems'
require 'bundler/setup'
$:.unshift File.expand_path('../../lib/', __FILE__)

require 'pulse-meter'
require 'mock_redis'

Bundler.require

Dir['spec/support/**/*.rb'].each do |f|
  require f
end

RSpec.configure do |config|
  config.before(:each) { PulseMeter.redis = MockRedis.new }

end

