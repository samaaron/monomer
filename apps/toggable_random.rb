#!/usr/bin/env jruby -wKU

#this app demonstrates the use of threads to allow interaction between the app and the listeners.

require File.dirname(__FILE__) + '/../lib/monome'

class ToggableRandom
  def initialize
    @monome = Monome::Monome.new
    @monome.listeners << Monome::Listeners::Toggle.new <<
                         Monome::Listeners::CornerToggles.new
  end
  
  def start
    monome_thread = Thread.new { @monome.start }
    random_thread = Thread.new do
      10000000.times do
        rand(10) < 5 ? sleep(rand(0.5) / 2.0) : sleep(rand(0.5) / 4.0)
        toggle_random_led
      end
    end
    monome_thread.join
    random_thread.join
  end
  
  def toggle_random_led
    x = rand(@monome.max_x + 1)
    y = rand(@monome.max_y + 1)
    @monome.toggle_led(x,y)
  end
end

ToggableRandom.new.start