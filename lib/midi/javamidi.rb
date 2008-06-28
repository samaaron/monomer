#!/usr/bin/env jruby

## see README

#shame I can't quite get this to have any effect
# lib_path = Java::JavaLang::System.getProperty("java.library.path")
# java_dir = File.expand_path(File.dirname(__FILE__) + '/../java/')
# puts java_dir
# Java::JavaLang::System.setProperty("java.library.path", java_dir + ':' + lib_path)
# puts "lib_path: " + Java::JavaLang::System.getProperty("java.library.path")

require 'rbconfig'

# `export CLASSPATH=$CLASSPATH:/Users/sam/Development/monomer/lib/java`
# $CLASSPATH.append File.dirname(__FILE__) + '/../java/'
# $CLASSPATH.append File.dirname(__FILE__) + '/../java'
# $CLASSPATH.append File.dirname(__FILE__) + '/../java/mmj/'
module Midi
  
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
    
    def send_bytes(bytes)
      @out.sendMidi(bytes)
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


  require File.dirname(__FILE__) + '/../java/mmj'

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