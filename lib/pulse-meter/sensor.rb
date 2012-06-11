require 'pulse-meter/sensor/base'
require 'pulse-meter/sensor/counter'
require 'pulse-meter/sensor/hashed_counter'
require 'pulse-meter/sensor/indicator'
require 'pulse-meter/sensor/remote'
require 'pulse-meter/sensor/uniq_counter'
require 'pulse-meter/sensor/timeline'
require 'pulse-meter/sensor/timelined/average'
require 'pulse-meter/sensor/timelined/counter'
require 'pulse-meter/sensor/timelined/hashed_counter'
require 'pulse-meter/sensor/timelined/min'
require 'pulse-meter/sensor/timelined/max'
require 'pulse-meter/sensor/timelined/percentile'
require 'pulse-meter/sensor/timelined/median'
require 'pulse-meter/sensor/timelined/uniq_counter'

# Top level sensor module
module PulseMeter

  # Atomic sensor data
  SensorData = Struct.new(:start_time, :value)

  # General sensor exception
  class SensorError < StandardError; end

  # Exception to be raised when sensor name is malformed
  class BadSensorName < SensorError
    def initialize(name, options = {})
      super("Bad sensor name: `#{name}', only a-z letters and _ are allowed")
    end
  end

  # Exception to be raised when Redis is not initialized
  class RedisNotInitialized < SensorError
    def initialize
      super("PulseMeter.redis is not set")
    end
  end

  # Exception to be raised when sensor cannot be dumped
  class DumpError < SensorError; end

  # Exception to be raised on attempts of using the same key for different sensors
  class DumpConflictError < DumpError; end

  # Exception to be raised when sensor cannot be restored
  class RestoreError < SensorError; end

  module Remote
    class MessageTooLarge < PulseMeter::SensorError; end
    class ConnectionError < PulseMeter::SensorError; end
  end
end
  
