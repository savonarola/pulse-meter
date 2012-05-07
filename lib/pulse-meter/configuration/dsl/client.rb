module PulseMeter
  module Configuration
    module Dsl
      class Client
        attr_reader :name, :remote

        def initialize(name, remote, &block)
          @name, @remote = name, remote
          instance_eval(&block)
        end

        def host(host = nil)
          if host
            @host = host
          else
            @host
          end
        end

        def port(port = nil)
          if port
            @port = port
          else
            @port
          end
        end
      end
    end
  end
end
