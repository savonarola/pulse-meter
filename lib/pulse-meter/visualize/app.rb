require 'sinatra/base'

module PulseMeter
  module Visualize
    class App < Sinatra::Base
      def initialize(layout)
        @layout = layout
        super()
      end

      configure :production, :development do
        enable :logging
      end

      get '/' do
        "Hello"
      end

      get '/pages' do
        content_type :json
        @layout.page_list.to_json
      end

    end
  end
end
