#!/usr/bin/env jruby -wKU

#monomer version of Stretta's press cafe: http://stretta.blogspot.com/2007/11/press-cafe.html

require File.dirname(__FILE__) + '/../lib/monomer'

class PressCoffee < Monomer::Listener
  
  before_start do
    @midi = Monomer::MidiOut.new
    @patterns = [
                 [0,0,0,0,0,0,0,1],
                 [0,0,1,0,0,1,0,0],
                 [1,1,0,0,1,1,0,0],
                 [1,1,1,0,0,0,1,1],
                 [0,0,0,1,1,1,0,0],
                 [1,0,0,1,1,1,0,1],
                 [0,1,0,1,1,1,0,0],
                 [1,1,1,1,1,1,1,1],
                ]
  end
  
  loop_on_key_sustain do |x,y|
    pattern = @patterns[y].clone
    loop do
      monome.light_column(x, *pattern)
      element = pattern.shift
      pattern.push element
      if pattern[0] == 1
        @midi.on(40 + x)
        sleep 0.15
        @midi.off(40 + x)
      else
        sleep 0.15
      end
      
    end
  end
  
  on_key_up do |x,y|
    monome.clear_column(x)
  end
  
  
end

Monomer::Monome.create.with_listeners(PressCoffee).start  if $0 == __FILE__