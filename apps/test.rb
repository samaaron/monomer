#!/usr/bin/env jruby -wKU

require File.dirname(__FILE__) + '/../lib/monomer'

class Test < Monome::Listener
  on_start do
  1.times do
   puts"#{monome.max_x}"
  end
  end
  
  on_key_down do |x,y|
    puts "#{x} - #{y}"
#    monome.status
  end
  
  on_key_up do |x,y|
  end
end

Monome::Monome.create.with_listeners(Test).start