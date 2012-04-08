module PulseMeter
  module Sensor
    class Indicator < Base

    def cleanup
      redis.del(value_key)
      super
    end

    protected

    def process_event(accessor, value)
      redis.set(value_key, value)
    end

    def value_key
      @value_key ||= "#{name}:value"
    end

  end
end

