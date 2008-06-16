# for list of osc commands see
# - http://docs.monome.org/doku.php?id=tech:protocol:osc
# - http://docs.monome.org/doku.php?id=tech:protocol:osc2

require 'osc'
module Monome
  class Communicator
    attr_accessor :listeners
    attr_reader :max_x, :max_y, :led_status
    
    def initialize(monome, state, prefix="/test", in_port=8000, out_port=8080)
      @monome = monome
      @state = state
      @prefix = prefix
      @client = OSC::SimpleClient.new('localhost', out_port)
      @server = OSC::SimpleServer.new(in_port)
    end
    
    def led_on(x,y)
      @client.send(OSC::Message.new("#{@prefix}/led", nil, x,y, 1))
      @state.notify(:message => :led_on, :time => Time.now, :x => x, :y => y)
    end
    
    def led_off(x,y)
      @client.send(OSC::Message.new("#{@prefix}/led", nil, x,y, 0))
      @state.notify(:message => :led_off, :time => Time.now, :x => x, :y => y)
    end
    
    # hook up methods to recieved osc messages
    def start
      @server.add_method(/^#{@prefix}\/press/i) do |mesg| do_press mesg end # how to do this correctly (the ruby way)?
      @server.add_method(/^#{@prefix}\/adc/i) do |mesg| do_adc mesg end
      @server.add_method(/^#{@prefix}\/prefix/i) do |mesg| do_prefix mesg end
      @server.add_method(nil) do |mesg| do_dump mesg end
      @server.run
    end
    
    def status
      @client.send(OSC::Message.new("/sys/report",nil))
    end
    
    private
      # do_ hooks to reacto on messages from monomeserial
      def do_press mesg
        x,y =  mesg.to_a[0..1]
        if mesg.to_a[2] == 1 
          @monome.button_pressed(x,y)
          @state.notify(:message => :button_pressed, :time => Time.now, :x => x, :y => y)
        else
          @monome.button_released(x,y)
          @state.notify(:message => :button_released, :time => Time.now, :x => x, :y => y)
        end
      end
      
      def do_adc mesg
        #puts "#{mesg.to_a.to_s}"
      end
      
      def do_prefix mesg
        puts "#{mesg.to_a.to_s}"
      end
      
      def do_dump mesg
        params = mesg.to_a.join(',')
        puts "#{mesg.address}: #{params}"
      end
  end
end

