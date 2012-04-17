require 'pulse-meter/sensor/base'
require 'pulse-meter/sensor/counter'
require 'pulse-meter/sensor/indicator'
require 'pulse-meter/sensor/timeline'
require 'pulse-meter/sensor/timelined/average'
require 'pulse-meter/sensor/timelined/counter'

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

end
  
