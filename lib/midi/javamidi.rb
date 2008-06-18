#!/usr/bin/env jruby

## see README

require 'rbconfig'
require 'java'

module Midi
  class Message
    # see http://tomscarff.tripod.com/midi_analyser/midi_messages.htm
    #
    # bbbb     - midi channel - 0000 to 1111
    # kkkkkkk  - note number  - 0000000 to 1111111
    # vvvvvvv  - velocity     - 0000000 to 1111111
    # nnnnnnn  - programm     - 0000000 to 1111111
    #                     status byte | data byte 1 | data byte 2
    ON  = 0b10010000     #  1001bbbb  |  0kkkkkkk   |  0vvvvvvv
    OFF = 0b10000000     #  1000bbbb  |  0kkkkkkk   |  0vvvvvvv
    PC  = 0b11000000     #  1100bbbb  |  0nnnnnnn   |
    ALL_OFF = 0b10110000 #  1011bbbb  |  01111011   |  00000000
  end
  
  class MessageOn < Message
    def initialize(channel, note, velocity=64)
      raise 'illegal channel' unless (1..16).include? channel
      raise 'illegal note' unless (0..127).include? note
      raise 'illegal velocity' unless (0..127).include? velocity
      @channel = channel - 1
      @note = note
      @velocity = velocity
    end
    
    def to_bytes
      b1 = ON + @channel
      b2 = @note
      b3 = @velocity
      return [b1, b2, b3]
    end
  end
  
  class MessageOff < Message
    def initialize(channel, note, velocity=64)
      raise 'illegal channel' unless (1..16).include? channel
      raise 'illegal note' unless (0..127).include? note
      raise 'illegal velocity' unless (0..127).include? velocity
      @channel = channel - 1
      @note = note
      @velocity = velocity
    end
    
    def to_bytes
      b1 = OFF + @channel
      b2 = @note
      b3 = @velocity
      return [b1, b2, b3]
    end
  end
 
  class MessageProgrammChange < Message
    def initialize(channel, programm)
      raise 'illegal channel' unless (1..16).include? channel
      raise 'illegal programm' unless (0..127).include? programm
      @type = ON
      @channel = channel -1
      @programm = programm
    end
    
    def to_bytes
      b1 = ON + @channel
      b2 = @programm
      return [b1, b2]
    end
  end 
  
  class MessageAllOff < Message
    def initialize(channel)
      raise 'illegal channel' unless (1..16).include? channel
      @channel = channel - 1
    end
    
    def to_bytes
      b1 = ON + @channel
      b2 = 0b01111011
      b3 = 0b00000000
      return [b1, b2, b3]
    end
  end
  
  class MidiListener
    def self.recieve(&block)
      meta_def :on_recieve do
        block
      end
      
      def recieve(mesg)
        Thread.new do
          self.class.on_recieve.call(mesg)
        end
      end
    end
  end
  
  class System
    @@singleton = nil
    def self.use
      return @@singleton = self.new if @@singleton.nil?
      @@singleton.reset
      return @@singleton
    end
    
    def reset
      int_reset
    end
    
    def devices
      int_devices
    end
    
    def inputs
      int_ins
    end
    
    def outputs
      int_outs
    end
  end
  
  class MidiIn
    def open
      int_open
    end
    
    def close
      int_close
    end
    ##TODO implement listener
  end
  
  class MidiOut
    def open
      int_open
    end
    
    def close
      int_close
    end
    
    def send(mesg)
      int_sent(mesg)
    end
    
    def reset
      [1..127].each do | channel |
        m = MessageAllOff.new channel
        message(m)
      end
    end
  end
  
  class MidiDevice
    def name
      int_name
    end
  end
    
if RUBY_PLATFORM.include?('java') and Config::CONFIG["host_os"].include?('darwin')

  # place mmj.jar && libmmj.jnilib in /Library/Java/Extensions and set classpath to include this folder
  # export CLASSPATH=$CLASSPATH:/Library/JAVA/Extensions

  #require File.dirname(__FILE__) + '/mmj'

  class System
    module MMJ
      include_package 'de.humatic.mmj'
    end
    
    def int_reset
      MMJ::MidiSystem.closeMidiSystem
    end
    
    def int_devices
      # maybe cache ?
      devs = []
      MMJ::MidiSystem.getDevices().to_a.each do |core_device|
        devs << MidiDevice.new(core_device)
      end
      devs
    end
    
    def int_ins
      ins = []
      MMJ::MidiSystem.getInputs.to_a.each do |midiIn, ix|
        ins << MidiIn.new(self, ix)
      end
      ins
    end
    
    def int_outs
      outs = []
      MMJ::MidiSystem.getOutputs.to_a.each_with_index do |midiOut, ix|
        outs << MidiOut.new(self, ix)
      end
      outs
    end
    
    def openMidiIn inIx
      MMJ::MidiSystem.openMidiInput inIx
    end
    
    def openMidiOut outIx
      MMJ::MidiSystem.openMidiOutput outIx
    end
  end
  
  class MidiIn
    def initialize system, inIx
      @system = system
      @inIx = inIx
      @in = nil
    end
    
    def int_open
      @in = @system.openMidiIn @inIx
    end
    
    def int_close
      raise 'MidiIn already closed' if @in.nil?
      @in.close
      @in = nil
    end
    
#    def int_listen(&block)
#      @in.addMidiListener
#    end
  end
  
  class MidiOut
    def initialize system, outIx
      @system = system
      @outIx = outIx
      @out = nil
    end
    
    def int_open
      @out = @system.openMidiOut @outIx
    end
    
    def int_close
      raise 'MidiOut already closed' if @out.nil?
      @out = nil
    end
    
    def int_sent(mesg)
      raise 'MidiOut not opened' if @out.nil?
      @out.sendMidi mesg.to_bytes.to_java(:byte)
    end
  end
  
  class MidiDevice
    module MMJ
      include_package 'de.humatic.mmj'
    end
    
    attr_reader :core_device
    
    def initialize core_device
      @core_device = core_device
    end
        
    def int_name
      core_device.getName
    end    
  end

else
  raise "Couldn't find a MIDI implementation for your platform"
end
end