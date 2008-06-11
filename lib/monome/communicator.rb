require 'osc'
module Monome
  class Communicator    
    attr_accessor :listeners
    attr_reader :max_x, :max_y, :led_status
    
    def initialize(monome, state, in_port=8000, out_port=8080)
      @monome = monome
      @state = state
      @client = OSC::SimpleClient.new('localhost', out_port)
      @server = OSC::SimpleServer.new(in_port)
    end
    
    def led_on(x,y)
      @client.send(OSC::Message.new('/test/led', nil, x,y, 1))
      @state.notify(:message => :led_on, :time => Time.now, :x => x, :y => y)
    end
    
    def led_off(x,y)
      @client.send(OSC::Message.new('/test/led', nil, x,y, 0))
      @state.notify(:message => :led_off, :time => Time.now, :x => x, :y => y)
    end
    
    def start
      @server.add_method(nil) do |mesg|
        x,y =  mesg.to_a[0..1]
        if mesg.to_a[2] == 1 
          @monome.button_pressed(x,y)
          @state.notify(:message => :button_pressed, :time => Time.now, :x => x, :y => y)
        else
          @monome.button_released(x,y)
          @state.notify(:message => :button_released, :time => Time.now, :x => x, :y => y)
        end
      end
      @server.run
    end
  end
end

