#!/usr/bin/env ruby -wKU

require '../lib/monome'

class Random
  def initialize
    @monome = Monome::Monome.new
  end
  
  def start
    10000000.times do
      sleep(0.1)
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