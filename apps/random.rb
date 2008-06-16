#!/usr/bin/env jruby -wKU

#Choose a random key and toggle it. Repeat lots of times.

require File.dirname(__FILE__) + '/../lib/monomer'

class Random
  def initialize
    @monome = Monome::Monome.new
  end
  
  def start
    10000000.times do
      sleep(rand(0.5))
      toggle_random_led
    end
  end
  
  def toggle_random_led
    x = rand(@monome.max_x + 1)
    y = rand(@monome.max_y + 1)
    @monome.toggle_led(x,y)
  end
end

Random.new.start