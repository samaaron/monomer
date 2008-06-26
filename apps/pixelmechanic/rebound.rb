#!/usr/bin/env jruby -wKUd

#monomer version of pixelmechanic's boiingg: http://docs.monome.org/doku.php?id=app:boiingg

require File.dirname(__FILE__) + '/../../lib/monomer'
class Rebound < Monomer::Listener
  
  before_start do
    @midi = Monomer::MidiOut.new
    @position  = [0] * monome.row_size
    @direction = [0] * monome.row_size
    @range     = [0] * monome.row_size
  end
  
  on_start do
    timely_repeat :period => 0.14, :pre_tick => L{update_patterns}, :on_tick => L{send_midi_and_light_monome}
  end
  
  on_key_down do |x,y|
    @range[x]    = y
    @direction[x]= -1 
    @position[x] = y
  end
  
  def self.update_patterns
    @range.each_with_index do |range, index|
      if range != 0
        @position[index] += @direction[index]
        @direction[index] *= -1 if @position[index] == 0 || @position[index] == range
      end
    end
  end
  
  def self.send_midi_and_light_monome
    @position.each_with_index do |position, index|
      monome.clear_column(index)
      if @range[index] != 0
        monome.led_on(index, position) 
        @midi.play(0.5, 40 + index) if position == 0
      end
    end
  end
  
end

Monomer::Monome.create.with_listeners(Rebound).start  if $0 == __FILE__