#!/usr/bin/env jruby -wKU

#Choose a random key and flash it. Repeat lots of times.

require File.dirname(__FILE__) + '/../../lib/monomer'

class Random < Monomer::Listener
  
  loop_on_start do
    flash_random_led
  end
  
  def self.flash_random_led
    x = monome.rand_x
    y = monome.rand_y
    monome.led_on(x,y)
    sleep 0.01
    monome.led_off(x,y)
  end
end

Monomer::Monome.create.with_listeners(Random).start  if $0 == __FILE__