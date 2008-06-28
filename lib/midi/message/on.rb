module Monomer
  module JMidi
    module Message
      class On
        include MessageCodes
        
        def initialize(channel, note, velocity=64)
          raise 'illegal channel' unless (1..16).include? channel
          raise 'illegal note' unless (0..127).include? note
          raise 'illegal velocity' unless (0..127).include? velocity
          @channel = channel - 1
          @note = note
          @velocity = velocity
        end
        
        def to_bytes
          b1 = ON + @channel
          b2 = @note
          b3 = @velocity
          return [b1, b2, b3]
        end
      end
    end
  end
end