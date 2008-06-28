module Monomer
  module JMidi
    module Message
      class AllOff
        include MessageCodes
        
        def initialize(channel)
          raise 'illegal channel' unless (1..16).include? channel
          @channel = channel - 1
        end

        def to_bytes
          b1 = ON + @channel
          b2 = 0b01111011
          b3 = 0b00000000
          return [b1, b2, b3]
        end
      end
    end
  end
end