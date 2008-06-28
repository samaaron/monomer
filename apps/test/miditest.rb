#!/usr/bin/env jruby -wKU

require File.dirname(__FILE__) + '/../../lib/monomer'

class Miditest < Monomer::Listener
  before_start do
    @midi = Monomer::MidiOut.new
  end
  
  on_any_button_press do |x,y|
    @midi.on (y * 8 + x)
    monome.led_on(x,y)
  end
  
  on_any_button_release do |x,y|
    @midi.off(y * 8 + x)
    monome.led_off(x,y)
  end
  
end

Monomer::Monome.create.with_listeners(Miditest).start  if $0 == __FILE__