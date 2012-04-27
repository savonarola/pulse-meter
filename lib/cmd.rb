require 'thor'
require 'terminal-table'

# Example:
# init_values = {:ttl => 3600, :raw_data_ttl => 600, :interval => 10, :reduce_delay => 3}
# max = PulseMeter::Sensor::Timelined::Max.new(:max, init_values)
# median = PulseMeter::Sensor::Timelined::Median.new(:median, init_values)

module Cmd
  class All < Thor
    no_tasks do
      def init_redis!
        redis = Redis.new :host => options[:host], :port => options[:port], :db => options[:db]
        PulseMeter.redis = redis
      end

      def all_sensors
        PulseMeter::Sensor::Timeline.list_objects
      end

      def all_sensors_table(title = '')
        table = Terminal::Table.new :title => title
        table << ["Name", "Class", "ttl", "raw data ttl", "interval", "reduce delay"]
        table << :separator
        all_sensors.each {|s| table << [s.name, s.class, s.ttl, s.raw_data_ttl, s.interval, s.reduce_delay]}
        table
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
      init_redis!
      puts all_sensors_table('Registered sensors')
    end

    desc "reduce", "Execute reduction for all sensors' raw data"
    common_options
    def reduce
      init_redis!
      puts all_sensors_table('Registered sensors to be reduced')
      puts "START"
      PulseMeter::Sensor::Timeline.reduce_all_raw
      puts "DONE"
    end

    desc "event NAME VALUE", "Send event VALUE to sensor NAME"
    common_options
    def event(name, value)
      init_redis!
      sensor = PulseMeter::Sensor::Base.restore name
      sensor.event value
      puts "DONE"
    rescue PulseMeter::RestoreError
      puts "Sensor #{name} is unknown or cannot be restored"
    end

    desc "timeline NAME SECONDS", "Get sensor's NAME timeline for last SECONDS"
    common_options
    def timeline(name, seconds)
      init_redis!
      sensor = PulseMeter::Sensor::Timeline.restore name
      table = Terminal::Table.new
      sensor.timeline(seconds).each {|data| table << [data.start_time, data.value || '-']}
      puts table
    rescue PulseMeter::RestoreError
      puts "Sensor #{name} is unknown or cannot be restored"
    end

    desc "delete NAME", "Delete sensor by name"
    common_options
    def delete(name)
      init_redis!
      sensor = PulseMeter::Sensor::Timeline.restore name
      sensor.cleanup
      puts "Sensor #{name} deleted"
    rescue PulseMeter::RestoreError
      puts "Sensor #{name} is unknown or cannot be restored"
    end

  end
end
