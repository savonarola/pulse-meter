module PulseMeter
  module Sensor
    class Counter < Base

    def cleanup
      redis.del(value_key)
      super
    end

    def incr
      event(1)
    end

    def event(value)
      redis.incrby(value_key, value.to_i)
    end

    protected

    def value_key
      @values_key ||= "#{name}:value"
    end
  end
end

