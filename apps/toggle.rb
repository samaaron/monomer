#!/usr/bin/env ruby -wKU

#$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require '../lib/monome'
require 'corner_toggles'
require 'rectangles'
require 'toggle'

class Paint
  include Monome
  def initialize
    @monome = Monome.new
    @monome.listeners << self << Listeners::CornerToggles.new << Listeners::Rectangles.new
  end
  
  def run
    @monome.run
  end
end

if $0 == __FILE__
  Paint.new.run 
end

