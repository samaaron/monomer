#!/usr/bin/env jruby -wKU

#this app demonstrates the use of threads to allow interaction between the app and the listeners.

require File.dirname(__FILE__) + '/../../lib/monomer'
require File.dirname(__FILE__) + '/random'
require File.dirname(__FILE__) + '/corner_toggles'
require File.dirname(__FILE__) + '/toggle'

Monomer::Monome.create.with_listeners(Toggle, CornerToggles, Random).start
