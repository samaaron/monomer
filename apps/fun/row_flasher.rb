#!/usr/bin/env jruby -wKUd

require File.dirname(__FILE__) + '/../../lib/monomer'

class RowFlasher < Monomer::Listener
  
  loop_on_button_sustain(0,:any) do |x,y|
    monome.light_row(y, ([1] * monome.row_size))
    sleep 0.1
    monome.light_row(y, ([0] * monome.row_size))
    sleep 0.1
  end
  
  on_button_release(0, :any) do |x,y|
    monome.light_row(y, ([0] * monome.row_size))
  end
  
end

Monomer::Monome.create.with_listeners(RowFlasher).start  if $0 == __FILE__