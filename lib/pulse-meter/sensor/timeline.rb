require 'securerandom'

module PulseMeter
  module Sensor
    # @abstract Represents timelined sensor: series of values,
    #   one value for each consequent time interval.
    class Timeline < Base
      include PulseMeter::Mixins::Utils

      MAX_TIMESPAN_POINTS = 1000
      MAX_INTERVALS = 100

      # @!attribute [r] interval
      #   @return [Fixnum] Rotation interval
      # @!attribute [r] ttl
      #   @return [Fixnum] How long summarized data will be stored before expiration
      # @!attribute [r] raw_data_ttl
      #   @return [Fixnum] How long unsummarized raw data will be stored before expiration
      # @!attribute [r] reduce_delay
      #   @return [Fixnum] Delay between end of interval and summarization
      attr_reader :interval, :ttl, :raw_data_ttl, :reduce_delay

      # Default values for some sensor parameters
      DEFAULTS = {
        :raw_data_ttl => 3600,
        :reduce_delay => 60,
      }
      
      # Initializes sensor with given name and parameters
      # @param name [String] sensor name
      # @option options [Fixnum] :interval Rotation interval
      # @option options [Fixnum] :ttl How long summarized data will be stored before expiration
      # @option options [Fixnum] :raw_data_ttl How long unsummarized raw data will be stored before expiration
      # @option options [Fixnum] :reduce_delay Delay between end of interval and summarization
      def initialize(name, options)
        @interval = assert_positive_integer!(options, :interval)
        @ttl = assert_positive_integer!(options, :ttl)
        @raw_data_ttl = assert_positive_integer!(options, :raw_data_ttl, DEFAULTS[:raw_data_ttl])
        @reduce_delay = assert_positive_integer!(options, :reduce_delay, DEFAULTS[:reduce_delay])
        super
      end

      # Clean up all sensor metadata and data
      def cleanup
        keys = redis.keys(raw_data_key('*')) + redis.keys(data_key('*'))
        multi do
          keys.each{|key| redis.del(key)}
        end
        super
      end

      # Processes event from the past
      # @param time [Time] event time
      # @param value event value
      def event_at(time, value = nil)
        multi do
          interval_id = get_interval_id(time)
          key = raw_data_key(interval_id)
          aggregate_event(key, value)
          redis.expire(key, raw_data_ttl)
        end
      end

      # Reduces data in given interval. 
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

      # Reduces data in all raw interval
      def reduce_all_raw
        time = Time.now
        min_time = time - reduce_delay  - interval
        max_depth = time - reduce_delay - interval * MAX_INTERVALS
        ids = []
        while (time > max_depth)
          time -= interval
          interval_id = get_interval_id(time)
          next if Time.at(interval_id) > min_time

          reduced_key = data_key(interval_id)
          raw_key = raw_data_key(interval_id)
          break if redis.exists(reduced_key)
          ids << interval_id
        end
        ids.reverse.each {|id| reduce(id)}
      end

      def self.reduce_all_raw
        list_objects.each do |sensor|
          sensor.reduce_all_raw if sensor.respond_to? :reduce_all_raw
        end
      end

      # Returts sensor data within some last seconds
      # @param time_ago [Fixnum] interval length in seconds
      # @return [Array<SensorData>]
      # @raise ArgumentError if argumets are not valid time objects
      def timeline(time_ago)
        raise ArgumentError unless time_ago.respond_to?(:to_i) && time_ago.to_i > 0
        now = Time.now
        timeline_within(now - time_ago.to_i, now)
      end

      # Returts sensor data within given time
      # @param from [Time] lower bound
      # @param till [Time] upper bound
      # @param skip_optimization [Boolean] must be set to true to skip interval optimization
      # @return [Array<SensorData>]
      # @raise ArgumentError if argumets are not valid time objects
      def timeline_within(from, till, skip_optimization = false)
        raise ArgumentError unless from.kind_of?(Time) && till.kind_of?(Time)
        start_time, end_time = from.to_i, till.to_i
        actual_interval = if skip_optimization
          interval
        else
          optimized_interval(start_time, end_time)
        end
        current_interval_id = get_interval_id(start_time) + actual_interval
        keys = []
        ids = []
        while current_interval_id < end_time
          ids << current_interval_id
          keys << data_key(current_interval_id)
          current_interval_id += actual_interval
        end
        values = keys.empty? ? [] : redis.mget(*keys)
        res = []
        ids.zip(values) do |(id, val)|
          res << if val.nil?
            get_raw_value(id)
          else
            sensor_data(id, val)
          end
        end
        res
      end

      # Returns sensor data for given interval making in-memory summarization
      #   and returns calculated value
      # @param interval_id [Fixnum]
      # @return [SensorData]
      def get_raw_value(interval_id)
        interval_raw_data_key = raw_data_key(interval_id)
        if redis.exists(interval_raw_data_key)
          sensor_data(interval_id, summarize(interval_raw_data_key))
        else
          sensor_data(interval_id, nil)
        end
      end

      # Drops sensor data within given time
      # @param from [Time] lower bound
      # @param till [Time] upper bound
      # @raise ArgumentError if argumets are not valid time objects
      def drop_within(from, till)
        raise ArgumentError unless from.kind_of?(Time) && till.kind_of?(Time)
        start_time, end_time = from.to_i, till.to_i
        current_interval_id = get_interval_id(start_time) + interval
        keys = []
        while current_interval_id < end_time
          keys << data_key(current_interval_id)
          keys << raw_data_key(current_interval_id)
          current_interval_id += interval
        end
        keys.empty? ? 0 : redis.del(*keys)
      end

      # Returns Redis key by which raw data for current interval is stored
      def current_raw_data_key
        raw_data_key(current_interval_id)
      end

      # Returns Redis key by which raw data for given interval is stored
      # @param id [Fixnum] interval id
      def raw_data_key(id)
        "pulse_meter:raw:#{name}:#{id}"
      end

      # Returns Redis key by which summarized data for given interval is stored
      # @param id [Fixnum] interval id
      def data_key(id)
        "pulse_meter:data:#{name}:#{id}"
      end

      # Returns interval id where given time is
      # @param time [Time]
      def get_interval_id(time)
        (time.to_i / interval) * interval
      end

      def self.on_interval_calculation(&proc)
        class_eval do
          alias_method :old_getter, :get_interval_id
          define_method :get_interval_id do |time|
            instance_exec(time, &proc)
          end
        end
      end

      def self.reset_interval_calculation
        class_eval do
          if method_defined? :old_getter
            alias_method :get_interval_id, :old_getter
          end
        end
      end

      # Returns current interval id
      # @return [Fixnum]
      def current_interval_id
        get_interval_id(Time.now)
      end

      # @abstract Registeres event for current interval identified by key
      # @param key [Fixnum] interval id
      # @param value [Object] value to be aggregated
      def aggregate_event(key, value)
        # simple
        redis.set(key, value)
      end

      # @abstract Summarizes all event within interval to a single value
      # @param key [Fixnum] interval_id 
      def summarize(key)
        # simple
        redis.get(key)
      end

      # @abstract Deflates data taken from redis as string preserving nil values
      # @param value [String] raw data
      def deflate_safe(value)
        value.nil? ? nil : deflate(value)
      rescue
        nil
      end

      private

      def deflate(value)
        # simple
        value
      end

      def sensor_data(interval_id, value)
        value = deflate(value) unless value.nil?
        SensorData.new(Time.at(interval_id), value)
      end

      # Processes event
      # @param value event value
      def process_event(value = nil)
        multi do
          current_key = current_raw_data_key
          aggregate_event(current_key, value)
          redis.expire(current_key, raw_data_ttl)
        end
      end

      # Makes interval optimization so that the requested timespan contains less than MAX_TIMESPAN_POINTS values
      # @param start_time [Fixnum] unix timestamp of timespan start
      # @param end_time [Fixnum] unix timestamp of timespan start
      # @return [Fixnum] optimized interval in seconds.
      def optimized_interval(start_time, end_time)
        res_interval = interval
        timespan = end_time - start_time
        while timespan / res_interval > MAX_TIMESPAN_POINTS - 1
          res_interval *= 2
        end
        res_interval
      end


    end
  end
end
