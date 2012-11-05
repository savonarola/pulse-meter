require "redis"
require "logger"
require "pulse-meter/version"
require "pulse-meter/mixins/dumper"
require "pulse-meter/mixins/utils"
require "pulse-meter/mixins/cmd"
require "pulse-meter/observer"
require "pulse-meter/sensor"
require "pulse-meter/sensor/configuration"

require "pulse-meter/command_aggregator/async"
require "pulse-meter/command_aggregator/sync"

module PulseMeter
  @@redis = nil

  def self.redis
    @@redis 
  end

  def self.redis=(redis)
    @@redis = redis
  end

  def self.command_aggregator
    @@command_aggregator ||= PulseMeter::CommandAggregator::Async.instance
  end

  def self.command_aggregator=(command_aggregator)
    @@command_aggregator = case command_aggregator
      when :sync; PulseMeter::CommandAggregator::Sync.instance
      when :async; PulseMeter::CommandAggregator::Async.instance
      else raise ArgumentError
    end
  end
end
