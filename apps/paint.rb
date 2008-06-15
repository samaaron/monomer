#!/usr/bin/env jruby -wKU

#this app demonstrates the power of the listener functionality. 
#Essentially all of the programming of the app is captured in the three listers:
#
#Monome::Listeners::Toggle
# a simple toggle listener that toggles a given key's led when pressed

#Monome::Listeners::CornerToggles.new
# a listener that listens out for four successive corner presses and clears/fills the monome depending in corner
#
#Monome::Listeners::Rectangles.new
# a listener that listens for four rectangle corner presses (in any order) and the final corner being tapped twice. A
# filled rectangle is then displayed

require File.dirname(__FILE__) + '/../lib/monome'

class Paint
  def initialize
    @monome = Monome::Monome.new
    @monome.listeners << Monome::Listeners::Toggle.new <<
                         Monome::Listeners::CornerToggles.new << 
                         Monome::Listeners::Rectangles.new
                         
  end
  
  def start
    @monome.start
  end
end

Paint.new.start 


