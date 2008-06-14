#!/usr/bin/env ruby -wKU

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


