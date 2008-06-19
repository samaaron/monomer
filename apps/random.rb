#!/usr/bin/env jruby -wKU

#Choose a random key and flash it. Repeat lots of times.

require File.dirname(__FILE__) + '/../lib/monomer'

class Random < Monomer::Listener
  on_start do
    10_000_000.times do
      flash_random_led
    end
  end
  
  def self.flash_random_led
    x = rand(monome.max_x + 1)
    y = rand(monome.max_y + 1)
    monome.led_on(x,y)
    sleep 0.001
    monome.led_off(x,y)
  end
end

Monomer::Monome.create.with_listeners(Random).start  if $0 == __FILE__