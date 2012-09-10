module PulseMeter
  module Sensor
    module Timelined
      # Calculates n'th percentile in interval
      class MultiPercentile < Timeline
        attr_reader :p_value

        def initialize(name, options)
          @p_value = assert_array!(options, :p, [])
          @p_value.each {|p| assert_ranged_float!({:percentile => p}, :percentile, 0, 1)}
          super(name, options)
        end

        def aggregate_event(key, value)
          redis.zadd(key, value, "#{value}::#{uniqid}")
        end

        def summarize(key)
          @p_value.each_with_object({}) do |p, acc|
            count = redis.zcard(key)
            percentile = if count > 0
              position = p > 0 ? (p * count).round - 1 : 0
              el = redis.zrange(key, position, position)[0]
              redis.zscore(key, el)
            else
              nil
            end
            acc[p] = percentile
          end.to_json
        end

        private
        
        def deflate(value)
          hash = JSON.parse(value)
          hash.each {|p, v| hash[p] = v.to_f}
          hash
        end

      end
    end
  end
end
