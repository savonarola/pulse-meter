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

    end
  end
end
