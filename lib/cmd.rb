require 'thor'
require 'terminal-table'
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
        all_sensors.each {|sensor| table << [sensor.name, sensor.class]}
        table
      end
    end

    method_option :host, :default => '127.0.0.1', :desc => "Redis host"
    method_option :port, :default => 6379, :desc => "Redis port"
    method_option :db, :default => 0, :desc => "Redis db"

    desc "sensors", "List all sensors available"
    def sensors
      init_redis!
      puts all_sensors_table('Registered sensors')
    end

    desc "reduce", "Execute reduction for all sensors' raw data"
    def reduce
      init_redis!
      puts all_sensors_table('Registered sensors to be reduced')
      puts "START"
      PulseMeter::Sensor::Timeline.reduce_all_raw
      puts "DONE"
    end
  end
end
