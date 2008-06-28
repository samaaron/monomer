module Monomer
  module JMidi
    module Message
      class ProgramChange
        include MessageCodes
        
        def initialize(channel, programm)
          raise 'illegal channel' unless (1..16).include? channel
          raise 'illegal programm' unless (0..127).include? programm
          @type = ON
          @channel = channel -1
          @programm = programm
        end

        def to_bytes
          b1 = ON + @channel
          b2 = @programm
          return [b1, b2]
        end
      end
    end
  end
end