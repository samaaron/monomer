#!/usr/bin/env jruby -wKU

#introduction of a nicer api, natively supporting threads (without you needing to know about it)

require File.dirname(__FILE__) + '/../../lib/monomer'

class Toggle < Monomer::Listener
  
  on_button_press do |x,y|
    monome.toggle_led(x,y)
  end

end

Monomer::Monome.create.with_listeners(Toggle).start if $0 == __FILE__