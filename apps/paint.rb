#!/usr/bin/env jruby -wKU

#this app demonstrates the power of the listener functionality. 
#Essentially all of the programming of the app is captured in the three listers:
#toggle, cornertoggles and rectangles (see corresponding listeners for their implementation)

require File.dirname(__FILE__) + '/../lib/monomer'
require File.dirname(__FILE__) + '/rectangles'
require File.dirname(__FILE__) + '/corner_toggles'
require File.dirname(__FILE__) + '/toggle'

Monome::Monome[128].with_listeners(Toggle, Rectangles, CornerToggles).start