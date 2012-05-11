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

				content_type :json
        camelize_keys(@layout.widgets(id)).to_json
			end

			get '/pages/:page_id/widgets/:id' do
				page_id = params[:page_id].to_i 
				id = params[:id].to_i 

				content_type :json
        camelize_keys(@layout.widget(page_id, id)).to_json
			end
    end
  end
end
