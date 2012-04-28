require 'pulse-meter/sensor/base'
require 'pulse-meter/sensor/counter'
require 'pulse-meter/sensor/hashed_counter'
require 'pulse-meter/sensor/indicator'
require 'pulse-meter/sensor/timeline'
require 'pulse-meter/sensor/timelined/average'
require 'pulse-meter/sensor/timelined/counter'
require 'pulse-meter/sensor/timelined/hashed_counter'
require 'pulse-meter/sensor/timelined/min'
require 'pulse-meter/sensor/timelined/max'
require 'pulse-meter/sensor/timelined/percentile'
require 'pulse-meter/sensor/timelined/median'

module PulseMeter

  SensorData = Struct.new(:start_time, :value)

  class SensorError < StandardError; end

  class BadSensorName < SensorError
    def initialize(name, options = {})
      super("Bad sensor name: `#{name}', only a-z letters and _ are allowed")
    end
  end

  class RedisNotInitialized < SensorError
    def initialize
      super("PulseMeter.redis is not set")
    end
  end

  class DumpError < SensorError; end
  class RestoreError < SensorError; end

end
  
