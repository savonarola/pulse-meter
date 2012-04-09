require 'pulse-meter/sensor/base'
require 'pulse-meter/sensor/counter'

module PulseMeter

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
  
