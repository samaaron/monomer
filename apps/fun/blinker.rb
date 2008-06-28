#!/usr/bin/env jruby -wKU

#introduction of a nicer api, natively supporting threads (without you needing to know about it)

require File.dirname(__FILE__) + '/../../lib/monomer'

class Blinker < Monomer::Listener
  
  loop_on_button_sustain do
    monome.all
    sleep(0.1)
    monome.clear
    sleep(0.1)
  end

end

Monomer::Monome.create.with_listeners(Blinker).start  if $0 == __FILE__