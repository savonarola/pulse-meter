require 'sequrerandom'

module PulseMeter
  module Sensor
    class Timeline < Base

    attr_reader :interval, :ttl, :raw_data_ttl

    def initialize(name, options)
      super
      @interval = assert_positive_integer!(options, :interval)
      @ttl = assert_positive_integer!(options, :ttl)
      @raw_data_ttl = assert_positive_integer!(options, :raw_data_ttl)
    end

    def cleanup
      keys = []
      keys << current_buket_id_key
      keys << current_buket_key
      redis.keys(raw_completed_bucket_key('*')).each do |key|
        keys << key
      end
      redis.keys(completed_bucket_key('*')).each do |key|
        keys << key
      end
      redis.multi
      keys.each{|key| redis.del(key)}
      redis.exec
    end

    def event(value)
      rotate
      aggregate_event(value)
    end

    protected
    
    @queue = :pulse_meter

    def current_buket_id_key
      "#{name}:current_buket_id"
    end


    def current_buket_key
      "#{name}:current_buket"
    end
    alias :current_key :current_buket_key

    def raw_completed_bucket_key(id)
      "#{name}:raw:#{id}"
    end

    def completed_bucket_key(id)
      "#{name}:comp:#{id}"
    end

    def current_buket_id
      (((Time.now.to_i / interval) + 1) * interval).to_s
    end

    def rotate
      old_id = redis.get(current_buket_id_key)
      current_id = current_buket_id
      if old_id < current_id
        raw_data_key = raw_completed_bucket_key(old_id)
        multi do
          redis.set(current_buket_id_key, current_id)
          redis.renamenx(current_buket_key, raw_data_key)
          redis.expire(raw_data_key, raw_data_ttl)
        end
        Resque.enqueue(self.class, raw_data_key, completed_bucket_key(old_id), options)
      end
    end

    def self.perform(summarize_from, summarize_to, options)
      redis = PulseMeter.redis
      tmp_key = temp_key(summarize_from, summarize_to)
      already_summarized = begin
        redis.rename(summarize_from, tmp_key)
        false
      rescue RuntimeError => e
        if e.to_s =~ /no such key/
          true
        else
          raise e
        end
      end
      unless already_summarized
        summarize(redis, tmp_key, summarize_to, options)
        redis.del(tmp_key)
        redis.expire(summarize_to, ttl)
      end
    end

    def self.temp_key(summarize_from, summarize_to)
      "#{name}:summarize:#{SecureRandom.hex(32)}"
    end

    def aggregate_event(value)
      # simple
      redis.set(current_buket_key, value)
    end

  end
end

