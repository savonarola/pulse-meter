require 'sinatra/base'
require 'haml'
require 'gon-sinatra'

module PulseMeter
  module Visualize
    class App < Sinatra::Base
      include PulseMeter::Mixins::Utils
      register Gon::Sinatra

      def initialize(layout)
        @layout = layout
        super()
      end

      configure :production, :development do
        enable :logging
      end

      get '/' do
        @title = @layout.title
        gon.pageTitles = @layout.page_titles
				gon.options = camelize_keys(@layout.options)
        haml :main
      end

			get '/pages/:id/widgets' do
				id = params[:id].to_i 

				widget_data = [
					{
            id: 1,
						title: "Widget 1 on page #{id}",
						type: :pie,
            values_title: 'Rabbit Count',
            width: 6,
            interval: id,
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
            id: 2,
						title: "Widget 2 on page #{id}",
						type: :pie,
            values_title: 'Croco Count',
            width: 4,
            interval: id,
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
						title: "Widget 3 on page #{id}",
						type: :pie,
            values_title: 'Rhino Count',
            width: 3,
            interval: id,
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
						title: "Widget 4 on page #{id}",
						type: :pie,
            values_title: 'Lama Count',
            width: 7,
            interval: id,
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
				content_type :json
        camelize_keys(widget_data).to_json
			end

			get '/pages/:page_id/widgets/:id' do
				page_id = params[:page_id].to_i 
				id = params[:id].to_i 

				widget_data = {
          id: id,
          title: "Widget #{id} on page #{page_id}",
          type: :pie,
          values_title: 'XXXX Count',
          width: 6,
          interval: id,
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
				content_type :json
        camelize_keys(widget_data).to_json
			end
    end
  end
end
