module PulseMeter
  module Visualize
    module SeriesExtractor
      class Simple
        def initialize(sensor)
          @sensor = sensor
        end

        def opts_to_add
          opts = {}
          opts[:color] = @sensor.color if @sensor.color
          opts[:name] = @sensor.annotation
          opts
        end

        def series_data(timeline_data)
          [{
            data: timeline_data.map{|sd| {x: sd.start_time.to_i*1000, y: to_float(sd.value)}}
          }.merge(opts_to_add)]
        end

        def point_data(value)
          [{
            y: to_float(value)
          }.merge(opts_to_add)]
        end

        protected

        def to_float(val)
          val && val.to_f
        end
      end


      class Hashed < Simple

        def parse_data(value)
          if value
            if value.is_a?(String)
              JSON.parse(value)
            else
              value
            end
          else
            {}
          end
        end

        def point_data(value)
          data = parse_data(value)
          data.keys.map do |k|
            {
              y: to_float(data[k]),
              name: series_title(k)
            }
          end
        end

        def series_title(key)
          annotation = @sensor.annotation
          if annotation && !annotation.empty?
            "#{annotation}: #{key}"
          else
            key
          end
        end

        def series_data(timeline_data)
          series_data = {}
          parsed_data = timeline_data.map do |sd|
            data = parse_data(sd.value)
            data.keys.each{|k| series_data[k] ||= {name: series_title(k), data: []}}
            [sd.start_time.to_i*1000, data]
          end

          series_names = series_data.keys.sort
          parsed_data.each do |data|
            series_names.each do |k|
              series_data[k][:data] << {x: data[0], y: to_float(data[1][k])}
            end
          end
          series_data.values
        end
      end
    end

    SPECIAL_SERIES_EXTRACTORS = {
      'HashedCounter' => SeriesExtractor::Hashed
    }.freeze

    DEFAULT_SERIES_EXTRACTOR = SeriesExtractor::Simple

    def extractor(sensor)
      key = sensor.type.to_s.split('::').last
      extractor_class = SPECIAL_SERIES_EXTRACTORS[key] || DEFAULT_SERIES_EXTRACTOR
      extractor_class.new(sensor)
    end

    module_function :extractor

  end
end


