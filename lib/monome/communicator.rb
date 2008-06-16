# for list of osc commands see
# - http://docs.monome.org/doku.php?id=tech:protocol:osc
# - http://docs.monome.org/doku.php?id=tech:protocol:osc2

require 'osc'
module Monome
  class Communicator
    attr_accessor :listeners
    attr_reader :max_x, :max_y, :led_status
    
    def initialize(monome, state, monome_type, prefix='monomer', in_port=8000, out_port=8080)
      @monome = monome
      @monome_type = monome_type
      @state = state
      @prefix = "/#{prefix}"
      @client = OSC::SimpleClient.new('localhost', out_port)
      @server = OSC::SimpleServer.new(in_port)
      set_sys_prefix
      set_sys_cable('up')
      fade_in_and_out
    end
    
    def led_on(x,y)
      send_led(x,y,1)
      @state.notify(:message => :led_on, :time => Time.now, :x => x, :y => y)
    end
    
    def led_off(x,y)
      send_led(x,y,0)
      @state.notify(:message => :led_off, :time => Time.now, :x => x, :y => y)
    end
    
    def clear
      @state.notify(:message => :clear, :time => Time.now)
      send_clear(0)
    end
    
    def all
      @state.notify(:message => :all, :time => Time.now)
      send_clear(1)
    end
    
    # hook up methods to recieved osc messages
    def start
      @server.add_method(/^#{@prefix}\/press/i)  { |mesg| do_press(mesg)  } 
      @server.add_method(/^#{@prefix}\/adc/i)    { |mesg| do_adc(mesg)    }
      @server.add_method(/^#{@prefix}\/prefix/i) { |mesg| do_prefix(mesg) }
      @server.add_method(nil)                    { |mesg| do_dump(mesg)   }
      @server.run
    end
    
    def status
      @client.send(OSC::Message.new("/sys/report",nil))
    end
    
    private
    
    def fade_in_and_out
      set_sys_intensity(0)
      all
      1.upto(99)  {|i| set_sys_intensity(i/100.0) ; sleep(0.01)}
      99.downto(1){|i| set_sys_intensity(i/100.0) ; sleep(0.001)}
      clear
      set_sys_intensity(0.99)
    end
    
    def set_sys_intensity(intensity)
      @client.send(OSC::Message.new("/sys/intensity", nil, intensity))
    end
    
    def set_sys_prefix
      @client.send(OSC::Message.new("/sys/prefix", nil, @prefix))
    end
    
    def set_sys_cable(orientation)
      @client.send(OSC::Message.new("/sys/cable", nil, orientation))
    end
    
    def send_led(x,y,led_status)
      @client.send(OSC::Message.new("#{@prefix}/led", nil, x,y, led_status))
    end
    
    def send_frame(offset_x, offset_y, c1, c2, c3, c4, c5, c6, c7, c8)
      @client.send(OSC::Message.new("#{@prefix}/frame", nil, offset_x, offset_y, c1, c2, c3, c4, c5, c6, c7, c8))
    end
    
    def send_clear(led_status)
      @client.send(OSC::Message.new("#{@prefix}/clear", nil, led_status))
    end
    
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

