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
          {
            data: timeline_data.map{|sd| {x: sd.start_time.to_i*1000, y: to_float(sd.value)}}
          }.merge(opts_to_add)
        end

        def point_data(value)
          {
            y: to_float(value)
          }.merge(opts_to_add)
        end

        protected

        def to_float(val)
          val && val.to_f
        end
      end

    end

    SPECIAL_SERIES_EXTRACTORS = {
    }.freeze

    DEFAULT_EXTRACTOR = SeriesExtractor::Simple

    def extractor(sensor)
      key = sensor.class.to_s.split('::').last
      extractor_class = SPECIAL_SERIES_EXTRACTORS[key] || DEFAULT_EXTRACTOR
      extractor_class.new(sensor)
    end

    module_function :extractor

  end
end


