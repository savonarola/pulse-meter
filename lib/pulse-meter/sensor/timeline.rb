require 'securerandom'

module PulseMeter
  module Sensor
    class Timeline < Base
      include PulseMeter::Mixins::Utils

      attr_reader :interval, :ttl, :raw_data_ttl, :reduce_delay

      def initialize(name, options)
        super
        @interval = assert_positive_integer!(options, :interval)
        @ttl = assert_positive_integer!(options, :ttl)
        @raw_data_ttl = assert_positive_integer!(options, :raw_data_ttl)
        @reduce_delay = assert_positive_integer!(options, :reduce_delay)
      end

      def cleanup
        keys = redis.keys(raw_data_key('*')) + redis.keys(data_key('*'))
        multi do
          keys.each{|key| redis.del(key)}
        end
        super
      end

      def event(value = nil)
        multi do
          current_key = current_raw_data_key
          aggregate_event(current_key, value)
          redis.expire(current_key, raw_data_ttl)
        end
      end

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

      def reduce_all_raw
        min_time = Time.now - reduce_delay - interval
        redis.keys(raw_data_key('*')).each do |key|
          interval_id = key.split(':').last
          next if Time.at(interval_id.to_i) > min_time
          reduce(interval_id)
        end
      end

      def timeline(time_ago)
        raise ArgumentError unless time_ago.respond_to?(:to_i) && time_ago.to_i > 0
        now = Time.now.to_i
        start_time = now - time_ago.to_i
        current_interval_id = get_interval_id(start_time) + interval
        res = []
        while current_interval_id < now
          res << get_timeline_value(current_interval_id)
          current_interval_id += interval
        end
        res
      end

      def get_timeline_value(interval_id)
        interval_data_key = data_key(interval_id)
        return SensorData.new(Time.at(interval_id), redis.get(interval_data_key)) if redis.exists(interval_data_key)
        interval_raw_data_key = raw_data_key(interval_id)
        return SensorData.new(Time.at(interval_id), summarize(interval_raw_data_key)) if redis.exists(interval_raw_data_key)
        SensorData.new(Time.at(interval_id), nil)
      end

      def current_raw_data_key
        raw_data_key(current_interval_id)
      end

      def raw_data_key(id)
        "raw:#{name}:#{id}"
      end

      def data_key(id)
        "data:#{name}:#{id}"
      end

      def get_interval_id(time)
        (time.to_i / interval) * interval
      end

      def current_interval_id
        get_interval_id(Time.now)
      end

      def aggregate_event(key, value)
        # simple
        redis.set(key, value)
      end

      def summarize(key)
        # simple
        redis.get(key)
      end

    end
  end
end

