require 'gon-sinatra'
require 'haml'
require 'sinatra/base'
require 'sinatra/partial'

module PulseMeter
  module Visualize
    class App < Sinatra::Base
      include PulseMeter::Mixins::Utils
      register Gon::Sinatra
      register Sinatra::Partial

      set :partial_template_engine, :haml

      def initialize(layout)
        @layout = layout
        super()
      end

      configure :production, :development do
        enable :logging
      end

      get '/' do
        @title = @layout.title
        gon.pageInfos = camelize_keys(@layout.page_infos)
        gon.options = camelize_keys(@layout.options)
        haml :main
      end

      get '/pages/:id/widgets' do
        id = params[:id].to_i 

        content_type :json
        camelize_keys(@layout.widgets(id - 1)).to_json
      end

      get '/pages/:page_id/widgets/:id' do
        page_id = params[:page_id].to_i 
        id = params[:id].to_i
        timespan = params[:timespan].to_i
				start_time = params[:startTime].to_i
				end_time = params[:endTime].to_i

        content_type :json
        camelize_keys(
					@layout.widget(
						page_id - 1,
						id - 1,
						timespan: timespan,
						start_time: start_time,
						end_time: end_time
					)
				).to_json
      end

      get '/sensors' do
        content_type :json
        camelize_keys(@layout.sensor_list).to_json
      end

      get '/dynamic_widget' do
				start_time = params[:startTime].to_i
				end_time = params[:endTime].to_i
        timespan = params[:timespan].to_i

        content_type :json
        camelize_keys(@layout.dynamic_widget(
          timespan: timespan,
          start_time: start_time,
          end_time: end_time,
          sensors: params[:sensor],
          type: params[:type])
        ).to_json
      end
    end
  end
end
