$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
$:.unshift File.dirname(__FILE__) + '/osc'
$:.unshift File.dirname(__FILE__) + '/monome'

#require core
require 'monome/communicator'
require 'monome/monome'
require 'monome/state'
require 'monome/message'
require 'monome/listener'

#require crazy shit
require '_why/metaid'

