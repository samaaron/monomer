module Monomer
  class MidiOut
    def initialize
      system = Midi::System.new
      first_output = system.outputs[0]
      first_output.open
      @midi_out = first_output
      @prepared_on_messages  = []
      @prepared_off_messages = []
      @prepared_off_lambdas  = []
    end
    
    def on(note, velocity=64)
      @midi_out.send(JMidi::Message::On.new(1, note, velocity))
    end
    
    
    def off(note, velocity=64)
        @midi_out.send(JMidi::Message::Off.new(1, note, velocity))
    end
    
    def play(duration, note, velocity=64)
      on(note, velocity)
      Thread.new do
        sleep duration
        off(note, velocity)
      end
    end
    
    def prepare_on(note, velocity=64)
      @prepared_on_messages << JMidi::Message::On.new(1, note, velocity).to_bytes.to_java(:byte)
    end
    
    def prepare_off(note, velocity=64)
      @prepared_off_messages << JMidi::Message::Off.new(1, note, velocity).to_bytes.to_java(:byte)
    end
    
    def prepare_note(opts={})
      duration = opts[:duration]
      note     = opts[:note]
      velocity = opts[:velocity] || 64
      
      prepare_on(note, velocity)
      @prepared_off_lambdas << lambda do 
        sleep(duration)
        off(note)
      end
    end
    
    def play_prepared_notes!
      @prepared_on_messages.each{|note| @midi_out.send_bytes(note)} 
      @prepared_on_messages = []
      
      if @prepared_off_lambdas != []
        Thread.new do
          @prepared_off_lambdas.each {|l| Thread.new {l.call} }
          @prepared_off_lambdas = []
        end
      end
      
      if @prepared_off_messages != []
        Thread.new do
          @prepared_off_messages.each{|silence| @midi_out.send_bytes(silence)}
          @prepared_off_messages = []
        end 
      end
    end
    
    def prepare(duration, notes, velocity=64)
      send_on = notes.map{|note| prepare_on(note, velocity)}
      send_off = notes.map{|note| prepare_off(note, velocity)}
      
      return lambda do 
        send_on.each{|note| @midi_out.send(note)}
        Thread.new do
          sleep duration
          send_off.each{|silence| @midi_out.send(silence)}
        end
      end
    end
  end
end
