module Enumerable
  require 'csv'
  require 'terminal-table'

  def convert_time
    map do |el|
      if el.is_a?(Time)
        el.to_i
      else
        el
      end
    end
  end

  def to_table(format = nil)
    if "csv" == format.to_s
      CSV.generate(:col_sep => ';') do |csv|
        self.each {|row| csv << row.convert_time}
      end
    else
      self.each_with_object(Terminal::Table.new) do |row, table|
        table << if row.respond_to?(:map)
          row.map(&:to_s)
        else
          row
        end
      end
    end
  end
end

module PulseMeter
  module Mixins
    # Mixin with command-line utilities
    module Cmd
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

      def all_sensors_table(format = nil)
        data = [
          ["Name", "Class", "ttl", "raw data ttl", "interval", "reduce delay"],
        ]
        data << :separator unless 'csv' == format.to_s
        all_sensors.each do |s|
          if s.kind_of? PulseMeter::Sensor::Timeline
            data << [s.name, s.class, s.ttl, s.raw_data_ttl, s.interval, s.reduce_delay]
          else
            data << [s.name, s.class] + [''] * 4
          end
        end
        data.to_table(format)
      end

      def fail!(description = nil)
        puts description if description
        exit 1
      end
    end
  end
end
