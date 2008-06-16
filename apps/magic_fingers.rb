#!/usr/bin/env jruby -wKU

require File.dirname(__FILE__) + '/../lib/monomer'

class MagicFingers < Monome::Listener
  
  on_key_down do |x,y|
    puts "self: #{self}"
    draw_toggle_square(x,y,1)
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

Monome::Monome[128].with_listeners(MagicFingers).start  if $0 == __FILE__
