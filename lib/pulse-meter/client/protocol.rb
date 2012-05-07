module PulseMeter
  module Client
    class Protocol
      TERMINATOR = "|"

      class << self
        def pack(key, value)
          "#{key.to_s.strip}#{TERMINATOR}#{value.to_s.strip}"
        end

        def unpack(data)
          splitted = data.split(TERMINATOR)
          return if splitted.empty?

          [splitted.first.to_sym, splitted.last]
        end
      end
    end
  end
end
