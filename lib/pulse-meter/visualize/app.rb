require 'sinatra/base'
require 'haml'
require 'gon-sinatra'

module PulseMeter
  module Visualize
    class App < Sinatra::Base
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
        haml :main
      end

			get '/pages/:id/widgets' do
				id = params[:id].to_i 
				content_type :json
				[
					{
						title: "Widget 1 on page #{id}",
						type: :pie
					},
					{
						title: "Widget 2 on page #{id}",
						type: :chart
					},
					{
						title: "Widget 3 on page #{id}",
						type: :chart
					}
				].to_json
			end

    end
  end
end
