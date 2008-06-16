#!/usr/bin/env jruby -wKU

#flashes the entire monome repeatedly ad nauseam...

require File.dirname(__FILE__) + '/../lib/monome'

class Random
  def initialize
    @monome = Monome::Monome.new
  end
  
  def start
    100.times do
      sleep 0.1
      @monome.all
      sleep 0.1
      @monome.clear
    end
  end
  
end

Random.new.start