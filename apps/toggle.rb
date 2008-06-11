#!/usr/bin/env ruby -wKU

#$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require '../lib/monome'

class Toggle
  def initialize
    @monome = Monome.new
    @monome.listeners << self
  end
  
  def call(x,y,status)
    toggle(x,y) if status
  end
  
  def toggle(x,y)
    @monome.toggle(x,y)
  end
  
  def run
    @monome.run
  end
end



if $0 == __FILE__

  Toggle.new.run 

end

