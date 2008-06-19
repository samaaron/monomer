$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

#require monomer
require 'monomer/monome'
require 'monomer/listener'
require 'monomer/midi_out'

#require core
require 'monomer/core/communicator'
require 'monomer/core/state'
require 'monomer/core/message'

#require osc
require 'osc/osc'

#require java and midi
if RUBY_PLATFORM.include?('java') 
  require 'java'
  require 'midi/javamidi'
end

#require crazy shit
require '_why/metaid'

