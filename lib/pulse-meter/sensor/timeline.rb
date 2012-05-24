require 'securerandom'

module PulseMeter
  module Sensor
    # @abstract Represents timelined sensor: series of values,
    #   one value for each consequent time interval.
    class Timeline < Base
      include PulseMeter::Mixins::Utils

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

      # Processes event
      def event(value = nil)
        multi do
          current_key = current_raw_data_key
          aggregate_event(current_key, value)
          redis.expire(current_key, raw_data_ttl)
        end
      end

      
      # Reduces data in given interval
      # @param interval_id [Fixnum] 
      def reduce(interval_id)
        interval_raw_data_key = raw_data_key(interval_id)
        return unless redis.exists(interval_raw_data_key)
        value = summarize(interval_raw_data_key)
        interval_data_key = data_key(interval_id)
        multi do
          redis.del(interval_raw_data_key)
          redis.set(interval_data_key, value)
          redis.expire(interval_data_key, ttl)
        end
      end

      # Reduces data in all raw interval
      def reduce_all_raw
        min_time = Time.now - reduce_delay - interval
        redis.keys(raw_data_key('*')).each do |key|
          interval_id = key.split(':').last
          next if Time.at(interval_id.to_i) > min_time
          reduce(interval_id)
        end
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
      # @return [Array<SensorData>]
      # @raise ArgumentError if argumets are not valid time objects
      def timeline_within(from, till)
        raise ArgumentError unless from.kind_of?(Time) && till.kind_of?(Time)
        start_time, end_time = from.to_i, till.to_i
        current_interval_id = get_interval_id(start_time) + interval
        res = []
        while current_interval_id < end_time
          res << get_timeline_value(current_interval_id)
          current_interval_id += interval
        end
        res
      end

      # Returns sensor data for given interval.
      #   If the interval is not over yet makes its data in-memory summarization
      #   and returns calculated value
      # @param interval_id [Fixnum]
      # @return [SensorData]
      def get_timeline_value(interval_id)
        interval_data_key = data_key(interval_id)
        return SensorData.new(Time.at(interval_id), redis.get(interval_data_key)) if redis.exists(interval_data_key)
        interval_raw_data_key = raw_data_key(interval_id)
        return SensorData.new(Time.at(interval_id), summarize(interval_raw_data_key)) if redis.exists(interval_raw_data_key)
        SensorData.new(Time.at(interval_id), nil)
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

    end
  end
end
