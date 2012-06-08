require 'thor'
require 'terminal-table'
require 'time'
require 'json'
require 'csv'

module Enumerable
  def to_table(format = nil)
    if "csv" == format
      CSV.generate(:col_sep => ';') do |csv|
        self.each {|row| csv << row}
      end
    else
      self.each_with_object(Terminal::Table.new) {|row, table| table << row}
    end
  end
end

module Cmd
  class All < Thor
    include PulseMeter::Mixins::Utils
    no_tasks do
      def with_redis
        PulseMeter.redis = Redis.new :host => options[:host], :port => options[:port], :db => options[:db]
        yield
      end

      def with_safe_restore_of(name, &block)
        with_redis do
          sensor = PulseMeter::Sensor::Base.restore(name)
          block.call(sensor)
        end
      rescue PulseMeter::RestoreError
        fail! "Sensor #{name} is unknown or cannot be restored"
      end

      def all_sensors
        PulseMeter::Sensor::Timeline.list_objects
      end

      def all_sensors_table
        data = [
          ["Name", "Class", "ttl", "raw data ttl", "interval", "reduce delay"],
          :separator
        ]
        all_sensors.each do |s|
          if s.kind_of? PulseMeter::Sensor::Timeline
            data << [s.name, s.class, s.ttl, s.raw_data_ttl, s.interval, s.reduce_delay]
          else
            data << [s.name, s.class] + ['-'] * 4
          end
        end
        data.to_table
      end

      def fail!(description = nil)
        puts description if description
        exit 1
      end

      def self.common_options
        method_option :host, :default => '127.0.0.1', :desc => "Redis host"
        method_option :port, :default => 6379, :desc => "Redis port"
        method_option :db, :default => 0, :desc => "Redis db"
      end
    end

    desc "sensors", "List all sensors available"
    common_options
    def sensors
      with_redis {puts all_sensors_table}
    end

    desc "reduce", "Execute reduction for all sensors' raw data"
    common_options
    def reduce
      with_redis do
        puts 'Registered sensors to be reduced'
        puts all_sensors_table
        PulseMeter::Sensor::Timeline.reduce_all_raw
        puts "DONE"
      end
    end

    desc "event NAME VALUE", "Send event VALUE to sensor NAME"
    common_options
    method_option :format, :default => :plain, :desc => "Event format: plain or json"
    def event(name, value)
      if "json" == options[:format]
        value = JSON.parse(value)
      end
      with_safe_restore_of(name) {|sensor| sensor.event(value)}
    end

    desc "timeline NAME SECONDS", "Get sensor's NAME timeline for last SECONDS"
    common_options
    method_option :format, :default => :table, :desc => "Output format: table or csv"
    def timeline(name, seconds)
      with_safe_restore_of(name) do |sensor|
        puts sensor.
          timeline(seconds).
          map {|data| [data.start_time, data.value || '-']}.
          to_table(options[:format])
      end
    end

    desc "timeline_within NAME FROM TILL", "Get sensor's NAME timeline in interval. Time format: YYYY-MM-DD HH:MM:SS"
    common_options
    method_option :format, :default => :table, :desc => "Output format: table or csv"
    def timeline_within(name, from, till)
      with_safe_restore_of(name) do |sensor|
        puts sensor.
          timeline_within(Time.parse(from), Time.parse(till)).
          map {|data| [data.start_time, data.value || '-']}.
          to_table(options[:format])
      end
    end

    desc "delete NAME", "Delete sensor by name"
    common_options
    def delete(name)
      with_safe_restore_of(name) {|sensor| sensor.cleanup}
      puts "Sensor #{name} deleted"
    end

    desc "create NAME TYPE", "Create sensor of given type"
    common_options
    method_option :interval, :required => true, :type => :numeric, :desc => "Rotation interval"
    method_option :ttl, :required => true, :type => :numeric, :desc => "How long summarized data will be stored"
    method_option :raw_data_ttl, :type => :numeric, :desc => "How long unsummarized raw data will be stored"
    method_option :reduce_delay, :type => :numeric, :desc => "Delay between end of interval and summarization"
    method_option :annotation, :type => :string, :desc => "Sensor annotation"
    def create(name, type)
      with_redis do
        klass = constantize("PulseMeter::Sensor::Timelined::#{type}")
        puts "PulseMeter::Sensor::Timelined::#{type}"
        fail! "Unknown sensor type #{type}" unless klass
        sensor = klass.new(name, options.dup)
        puts "Sensor created"
        puts all_sensors_table
      end
    end

    desc "create_simple NAME TYPE", "Create simple non-timelined sensor of given type"
    common_options
    method_option :annotation, :type => :string, :desc => "Sensor annotation"
    def create_simple(name, type)
      with_redis do
        klass = constantize("PulseMeter::Sensor::#{type}")
        fail! "Unknown sensor type #{type}" unless klass
        sensor = klass.new(name, options.dup)
        puts "Sensor created"
        puts all_sensors_table
      end
    end

    desc "value NAME", "Get value of non-timelined sensor"
    def value(name)
      with_safe_restore_of(name) do |sensor|
        fail! "Sensor #{name} has no value method" unless sensor.respond_to?(:value)
        puts "Value: #{sensor.value}"
      end
    end

  end
end
