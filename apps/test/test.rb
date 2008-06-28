#!/usr/bin/env jruby -wKU

require File.dirname(__FILE__) + '/../../lib/monomer'

class Test < Monomer::Listener
  on_start do
    1.times do
     puts"#{monome.max_x}"
    end
  end
  
  on_button_press do |x,y|
    puts "#{x} - #{y}"
  end
  
  on_any_button_release do |x,y|
  end
end

Monomer::Monome.create.with_listeners(Test).start  if $0 == __FILE__