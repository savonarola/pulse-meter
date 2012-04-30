require 'sinatra/base'

module PulseMeter
  module Visualize
    class App < Sinatra::Base
      configure :production, :development do
        enable :logging
      end


      get '/' do
        "Hello"
      end

    end
  end
end
