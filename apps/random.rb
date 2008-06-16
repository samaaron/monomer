#!/usr/bin/env jruby -wKU

#Choose a random key and toggle it. Repeat lots of times.

require File.dirname(__FILE__) + '/../lib/monomer'

class Random
  def initialize
    @monome = Monome::Monome.new
  end
  
  def start
    10000000.times do
      #sleep(rand(0.5))
      flash_random_led
    end
  end
  
  def flash_random_led
    x = rand(@monome.max_x + 1)
    y = rand(@monome.max_y + 1)
    @monome.led_on(x,y)
    sleep 0.001
    @monome.led_off(x,y)
  end
end

Random.new.start