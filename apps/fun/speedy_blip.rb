#!/usr/bin/env jruby -wKU

#whizz one led through all the keys really, really fast

require File.dirname(__FILE__) + '/../../lib/monomer'

class SpeedyBlip < Monomer::Listener
  on_start do
    previous_x = 0
    previous_y = 0
    100.times do
      (0..monome.max_x).each do |x| 
        (0..monome.max_y).each do |y| 
          sleep 0.03
          monome.led_on(x,y)
          monome.led_off(previous_x, previous_y)
          previous_x = x
          previous_y = y
        end
      end
    end
  end
end

Monomer::Monome.create.with_listeners(SpeedyBlip).start  if $0 == __FILE__