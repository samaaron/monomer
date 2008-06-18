#!/usr/bin/env jruby -wKU

require File.dirname(__FILE__) + '/../lib/monomer'
require File.dirname(__FILE__) + '/../lib/midi/javamidi'

class Miditest < Monome::Listener
  on_start do
    puts "getting midi system"
    s = Midi::System.new
    puts "getting 1st midiout"
    @mOut = s.outputs[0]
    puts "opening midiout"
    @mOut.open # we need a listener to on_end to close the midi ports
    puts "done"
  end
  
  on_key_down do |x,y|
    note = y * 8 + x
    m = Midi::MessageOn.new 1, note
    puts "on #{x} | #{y} - #{note} - #{m}"
    @mOut.send m
  end
  
  on_key_up do |x,y|
    note = y * 8 + x
    m = Midi::MessageOff.new 1, note
    puts "off #{x} | #{y} - #{note} - #{m}"
    @mOut.send m
  end
end

Monome::Monome.create.with_listeners(Miditest).start  if $0 == __FILE__