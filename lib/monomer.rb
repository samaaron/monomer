$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

#require core
require 'monomer/core/timer'
require 'monomer/core/led'
require 'monomer/core/lights'
require 'monomer/core/message'
require 'monomer/core/communicator'
require 'monomer/core/state'

#require monomer
require 'monomer/midi_out'
require 'monomer/monome'
require 'monomer/listener'
require 'monomer/coord'

#require osc
require 'osc/osc'

#require java and midi
if RUBY_PLATFORM.include?('java') 
  require 'java'
  require 'midi/javamidi'
  
  #require messages
  require 'midi/message/message_codes'
  require 'midi/message/on'
  require 'midi/message/off'
  require 'midi/message/program_change'
  require 'midi/message/all_off'
end

#require crazy shit
require '_why/metaid'

#handy shortcut
alias :L :lambda


