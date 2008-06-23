#!/usr/bin/env jruby -wKU

#monomer version of Stretta's Blinken Park: http://docs.monome.org/doku.php?id=app:blinken_park

require File.dirname(__FILE__) + '/../lib/monomer'

class BlinkinLights < Monomer::Listener
  before_start do
    @spawn_rate = 1
    @sustain = 3
  end
  
  on_start do
    loop do
      monome.spawn do
        light_random_led(@sustain)
      end
      sleep @spawn_rate
    end
  end
  
  on_key_down do |x,y|
    @spawn_rate = ((x.to_f / monome.max_x.to_f) * 1) + 0.01
    @sustain = y + 0.1
    puts "spawn_rate: #{@spawn_rate}"
    puts "sustain:    #{@sustain}"
  end
  
  def self.light_random_led(sustain)
    x = rand(monome.max_x + 1)
    y = rand(monome.max_y + 1)
    monome.led_on(x,y)
    sleep sustain
    monome.led_off(x,y)
  end
  
end

Monomer::Monome.create.with_listeners(BlinkinLights).start  if $0 == __FILE__