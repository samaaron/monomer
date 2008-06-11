#!/usr/bin/env ruby -wKU

#$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require '../lib/monome'
require 'corner_toggles'

class Toggle
  include Monome
  def initialize
    @monome = Monome.new
    @monome.listeners << self << Listeners::CornerToggles.new
  end
  
  def button_pressed(x,y)
     @monome.toggle_led(x,y)
  end
  
  def run
    @monome.run
  end
end

if $0 == __FILE__
  Toggle.new.run 
end

