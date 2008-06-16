#!/usr/bin/env jruby -wKU

#introduction of a nicer api, natively supporting threads (without you needing to know about it)

require File.dirname(__FILE__) + '/../lib/monome'

class Blinker < Monome::Listener
  
  loop_on_key_sustain do
    monome.all
    sleep(0.1)
    monome.clear
    sleep(0.1)
  end

end

Monome::Monome.with_listeners(Blinker).start