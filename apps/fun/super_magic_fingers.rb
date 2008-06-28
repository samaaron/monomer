#!/usr/bin/env jruby -wKU

#this app demonstrates the ability to respond to sustained key presses.
#Press and hold a bunch of keys: madness!

require File.dirname(__FILE__) + '/../../lib/monomer'

class SuperMagicFingers < Monomer::Listener
  before_start do
    @magic_squares = {}
  end
  
  loop_on_button_sustain do |x,y|
    square_size = 1
    diff = 1
    loop do
      draw_toggle_square(x,y,square_size)
      sleep 0.01
      diff *= -1 if square_size == 16 || square_size == 0
      square_size += diff
    end
  end
  
  def self.draw_toggle_square(x,y,size)
    monome.toggle_led(x + size ,y + size)
    monome.toggle_led(x + size ,y       )
    monome.toggle_led(x        ,y + size)
    monome.toggle_led(x - size ,y - size)
    monome.toggle_led(x - size ,y       )
    monome.toggle_led(x        ,y - size)
    monome.toggle_led(x - size ,y + size)
    monome.toggle_led(x + size ,y - size)
  end
end

Monomer::Monome.create.with_listeners(SuperMagicFingers).start  if $0 == __FILE__

