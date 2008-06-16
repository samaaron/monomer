#!/usr/bin/env jruby -wKU

#this app demonstrates the ability to respond to sustained key presses.
#Press and hold a bunch of keys: madness!

require File.dirname(__FILE__) + '/../lib/monomer'

class MagicFingers
  def initialize
    @monome = Monome::Monome.new
    @monome.listeners << self << Monome::Listeners::CornerToggles.new
    @magic_squares = {}
  end
  
  def button_pressed(x,y)
    thread = Thread.new do
      square_size = 1
      diff = 1
      loop do
        draw_toggle_square(x,y,square_size)
        sleep 0.01
        diff *= -1 if square_size == 16 || square_size == 0
        square_size += diff
      end
    end
    @magic_squares[[x,y]] = thread
  end
  
  def button_released(x,y)
    @magic_squares[[x,y]].kill
  end
  
  def draw_toggle_square(x,y,size)
    @monome.toggle_led(x + size ,y + size)
    @monome.toggle_led(x + size ,y       )
    @monome.toggle_led(x        ,y + size)
    @monome.toggle_led(x - size ,y - size)
    @monome.toggle_led(x - size ,y       )
    @monome.toggle_led(x        ,y - size)
    @monome.toggle_led(x - size ,y + size)
    @monome.toggle_led(x + size ,y - size)
  end
  
  def start
    @monome.start
  end
end

MagicFingers.new.start 


