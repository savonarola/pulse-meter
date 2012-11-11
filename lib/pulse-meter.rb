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

  # Returns global Redis client
  def self.redis
    @@redis 
  end

  # Sets global Redis client
  # @param redis [Redis] redis client
  def self.redis=(redis)
    @@redis = redis
  end

  # Returns global command aggegator (i.e. object that accumulates Redis commands emitted by events and sends them into client)
  def self.command_aggregator
    @@command_aggregator ||= PulseMeter::CommandAggregator::Async.instance
  end
  
  # Sets global command_aggregator
  # @param type [Symbol] type of command aggegator (:async or :sync)
  # @raise [ArgumentError] if type is none of :async, :sync
  def self.command_aggregator=(command_aggregator)
    @@command_aggregator = case command_aggregator
      when :sync; PulseMeter::CommandAggregator::Sync.instance
      when :async; PulseMeter::CommandAggregator::Async.instance
      else raise ArgumentError
    end
  end

  # Sets global logger for all PulseMeter error messages
  # @param logger [Logger] logger to be used
  def self.logger=(new_logger)
    @@logger = new_logger
  end

  # Returns global PulseMeter logger
  def self.logger
    @@logger ||= begin 
      logger = Logger.new($stderr)
      logger.datetime_format = '%Y-%m-%d %H:%M:%S.%3N'
      logger
    end
  end

  # Sends error message to PulseMeter logger
  # @param message [String] error message
  def self.error(msg)
    logger.error(msg)
  end
end
