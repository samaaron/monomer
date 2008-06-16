#!/usr/bin/env jruby -wKU

#flashes the entire monome repeatedly ad nauseam...

require File.dirname(__FILE__) + '/../lib/monomer'

class Random < Monome::Listener
  
  on_start do
    100.times do
      sleep 0.1
      @monome.all
      sleep 0.1
      @monome.clear
    end
  end
  
end

Monome::Monome[128].with_listeners(Random).start