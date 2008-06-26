module Monomer
  class MidiOut
    def initialize
      system = Midi::System.new
      first_output = system.outputs[0]
      first_output.open
      @midi_out = first_output
    end
    
    def on(note, velocity=1)
      @midi_out.send(Midi::MessageOn.new(velocity, note))
    end
    
    
    def off(note, velocity=1)
      @midi_out.send(Midi::MessageOff.new(velocity, note  ))
    end
    
    def play(duration, note, velocity=1)
      on(note, velocity)
      Thread.new do
        sleep duration
        off(note, velocity)
      end
    end
  end
end
