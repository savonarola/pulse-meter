require 'rubygems'
require 'bundler/setup'
$:.unshift File.expand_path('../../lib/', __FILE__)

require 'pulse-meter'

Bundler.require

Dir['spec/support/**/*.rb'].each do |f|
  require f
end

RSpec.configure do |config|
end

