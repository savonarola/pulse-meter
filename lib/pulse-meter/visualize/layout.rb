module PulseMeter
  module Visualize
    class Layout
      attr_reader :pages

      attr_reader :title
      attr_reader :redraw_interval
      attr_reader :use_utc

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @title = args[:title] or raise ArgumentError, ":title not specified"
        @pages = args[:pages] or raise ArgumentError, ":pages not specified"
        @use_utc = args[:use_utc]
      end

      def to_app
        PulseMeter::Visualize::App.new(self)
      end

			def page_titles
				res = []
				pages.each_with_index do |p, i|
					res << {
						id: i + 1,
						title: p.title
					}
				end
				res
			end

			def options
				{
					use_utc: @use_utc
				}
      end


      def widget(page_id, widget_id)
        widgets(page_id)[widget_id - 1]
      end

      def widgets(page_id)
        widget_data = [
            {
                id: 1,
                title: "Widget 1 on page #{page_id}",
                type: :pie,
                values_title: 'Rabbit Count',
                width: 6,
                interval: 10,
                series: [
                    {
                        type: :pie,
                        name: "Rabbit Count",
                        data: [
                            ['Sensor 1', Random.rand(1000)],
                            ['Sensor 2', Random.rand(1000)],
                            ['Sensor 3', Random.rand(1000)]
                        ]
                    }
                ]
            },
            {
                id: 2,
                title: "Widget 2 on page #{page_id}",
                type: :spline,
                values_title: 'Croco Count',
                width: 4,
                interval: 10,
                series: [
                    {
                        name: 'Sensor 1',
                        data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]},
                    },
                    {
                        name: 'Sensor 2',
                        data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]}
                    }
                ]
            },
            {
                id: 3,
                title: "Widget 3 on page #{page_id}",
                type: :line,
                values_title: 'Rhino Count',
                width: 3,
                interval: 10,
                series: [
                    {
                        name: 'Sensor 1',
                        data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]},
                    },
                    {
                        name: 'Sensor 2',
                        data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]}
                    }
                ]
            },
            {
                id: 4,
                title: "Widget 4 on page #{page_id}",
                type: :spline,
                values_title: 'Lama Count',
                width: 7,
                interval: 10,
                series: [
                    {
                        name: 'Sensor 1',
                        data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]},
                    },
                    {
                        name: 'Sensor 2',
                        data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]}
                    }
                ]
            }
        ]

      end






	
    end
  end
end
