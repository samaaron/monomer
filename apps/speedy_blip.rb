#!/usr/bin/env ruby -wKU

require File.dirname(__FILE__) + '/../lib/monome'

class Random
  def initialize
    @monome = Monome::Monome.new
  end
  
  def start
    previous_x = 0
    previous_y = 0
    100.times do
      (0..@monome.max_x).each do |x| 
        (0..@monome.max_y).each do |y| 
          sleep 0.03
          @monome.led_on(x,y)
          @monome.led_off(previous_x, previous_y)
          previous_x = x
          previous_y = y
        end
      end
    end
  end
  
end

Random.new.start