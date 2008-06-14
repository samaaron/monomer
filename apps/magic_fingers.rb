#!/usr/bin/env ruby -wKU

require File.dirname(__FILE__) + '/../lib/monome'

class MagicFingers
  def initialize
    @monome = Monome::Monome.new
    @monome.listeners << self << Monome::Listeners::CornerToggles.new
  end
  
  def button_pressed(x,y)
    draw_toggle_square(x,y,1)
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


