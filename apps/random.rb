#!/usr/bin/env ruby -wKU

require File.dirname(__FILE__) + '/../lib/monome'

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