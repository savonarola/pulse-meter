module PulseMeter
  module Sensor
    # Methods for reducing raw data to single values
    module TimelineReduce
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      MAX_INTERVALS = 100

      # @note Interval id is
      #   just unixtime of its lower bound. Ruduction is a process
      #   of 'compressing' all interval's raw data to a single value.
      #   When reduction is done summarized data is saved to Redis
      #   separately with expiration time taken from sensor configuration.
      # @param interval_id [Fixnum] 
      def reduce(interval_id)
        interval_raw_data_key = raw_data_key(interval_id)
        return unless redis.exists(interval_raw_data_key)
        value = summarize(interval_raw_data_key)
        interval_data_key = data_key(interval_id)
        multi do
          redis.del(interval_raw_data_key)
          if redis.setnx(interval_data_key, value)
            redis.expire(interval_data_key, ttl)
          end
        end
      end

      # Reduces data in all raw intervals
      def reduce_all_raw
        time = Time.now
        min_time = time - reduce_delay  - interval
        max_depth = time - reduce_delay - interval * MAX_INTERVALS
        ids = collect_ids_to_reduce(time, max_depth, min_time)
        ids.reverse.each {|id| reduce(id)}
      end

      def collect_ids_to_reduce(time, time_from, time_to)
        ids = []
        while (time > time_from) # go backwards
          time -= interval
          interval_id = get_interval_id(time)
          next if Time.at(interval_id) > time_to

          reduced_key = data_key(interval_id)
          raw_key = raw_data_key(interval_id)
          break if redis.exists(reduced_key)
          ids << interval_id
        end
        ids
      end

      module ClassMethods

        def reduce_all_raw
          list_objects.each do |sensor|
            sensor.reduce_all_raw if sensor.respond_to? :reduce_all_raw
          end
        end

      end

    end
  end
end

