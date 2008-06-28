#!/usr/bin/env jruby -wKUd

require File.dirname(__FILE__) + '/../../lib/monomer'

class SoloToggler < Monomer::Listener
  
  on_button_press(0,:any) do |x,y|
    monome.toggle_led(x,y)
  end
  
end

Monomer::Monome.create.with_listeners(SoloToggler).start  if $0 == __FILE__