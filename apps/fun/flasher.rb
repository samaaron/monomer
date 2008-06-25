#!/usr/bin/env jruby -wKU

#flashes the entire monome repeatedly ad nauseam...

require File.dirname(__FILE__) + '/../../lib/monomer'

class Flasher < Monomer::Listener
  
  on_start do
    100.times do
      sleep 0.1
      monome.all
      sleep 0.1
      monome.clear
    end
  end
  
end

Monomer::Monome.create.with_listeners(Flasher).start  if $0 == __FILE__