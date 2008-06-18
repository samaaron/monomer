$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

#require core
require 'monomer/communicator'
require 'monomer/monome'
require 'monomer/state'
require 'monomer/message'
require 'monomer/listener'
require 'monomer/midi_out'

#require osc
require 'osc/osc'

#require java and midi
require 'java'
require 'midi/javamidi'

#require crazy shit
require '_why/metaid'

