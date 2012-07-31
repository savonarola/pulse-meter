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

				content_type :json
        camelize_keys(@layout.widget(page_id - 1, id - 1, timespan: timespan)).to_json
			end

      get '/sensors' do
        content_type :json
        camelize_keys(@layout.sensor_list).to_json
      end

      get '/dynamic_widget' do
        content_type :json
        {}
      end
    end
  end
end
