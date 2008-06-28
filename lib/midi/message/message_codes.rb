module Monomer
  module JMidi
    module Message
      module MessageCodes
        # see http://tomscarff.tripod.com/midi_analyser/midi_messages.htm
        #
        # bbbb     - midi channel - 0000 to 1111
        # kkkkkkk  - note number  - 0000000 to 1111111
        # vvvvvvv  - velocity     - 0000000 to 1111111
        # nnnnnnn  - programm     - 0000000 to 1111111
        #                     status byte | data byte 1 | data byte 2
        ON  = 0b10010000     #  1001bbbb  |  0kkkkkkk   |  0vvvvvvv
        OFF = 0b10000000     #  1000bbbb  |  0kkkkkkk   |  0vvvvvvv
        PC  = 0b11000000     #  1100bbbb  |  0nnnnnnn   |
        ALL_OFF = 0b10110000 #  1011bbbb  |  01111011   |  00000000
      end
    end
  end
end
    