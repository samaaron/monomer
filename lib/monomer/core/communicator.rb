# for list of osc commands see
# - http://docs.monome.org/doku.php?id=tech:protocol:osc
# - http://docs.monome.org/doku.php?id=tech:protocol:osc2

module Monomer
  module Core
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
      end
      
      def led_off(x,y)
        send_led(x,y,0)
      end
      
      def light_column(col, *pattern)
        split_patterns = []
        (0...(pattern.size / 8)).each {|i| split_patterns << pattern.slice(i*8, 8)}
        split_patterns.map!{|i| i.to_s.to_i(2)}
        send_col(col, split_patterns)
      end
      
      def light_row(row, *pattern)
        split_patterns = []
        (0...(pattern.size / 8)).each {|i| split_patterns << pattern.slice(i*8, 8)}
        split_patterns.map!{|i| i.to_s.to_i(2)}
        send_row(row, split_patterns)
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
      def start(&block)
        @server.add_method(/^#{@prefix}\/press/i)  { |mesg| do_press(mesg)  } 
        @server.add_method(/^#{@prefix}\/adc/i)    { |mesg| do_adc(mesg)    }
        @server.add_method(/^#{@prefix}\/prefix/i) { |mesg| do_prefix(mesg) }
        @server.add_method(/^\/sys\//i)            { |mesg| do_sys(mesg)    }
    
        get_sys_report # send initial request to gather unit data. is this the right place for it?
        @device_detected = false
        @server.run(&block)
      end
      
      def status
        get_sys_report
      end
      
      private
      
      def fade_in_and_out
        set_sys_intensity(0)
        draw_inverted_naeu
        1.upto(99)  {|i| set_sys_intensity(i/100.0) ; sleep(0.01)}
        99.downto(1){|i| set_sys_intensity(i/100.0) ; sleep(0.002)}
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
      
      def get_sys_report
        @client.send(OSC::Message.new("/sys/report",nil))
      end
      
      def send_led(x,y,led_status)
        @client.send(OSC::Message.new("#{@prefix}/led", nil, x,y, led_status))
      end
      
      def send_row(row_num, decimals)
        @client.send(OSC::Message.new("#{@prefix}/led_row", nil, row_num, *decimals))
      end
      
      def send_col(col_num, decimals)
        @client.send(OSC::Message.new("#{@prefix}/led_col", nil, col_num, *decimals))
      end
      
      def send_frame(offset_x, offset_y, c1, c2, c3, c4, c5, c6, c7, c8)
        @client.send(OSC::Message.new("#{@prefix}/frame", nil, offset_x, offset_y, c1, c2, c3, c4, c5, c6, c7, c8))
      end
      
      def send_clear(led_status)
        @client.send(OSC::Message.new("#{@prefix}/clear", nil, led_status))
      end
      
      # do_ hooks to react on messages from monomeserial
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
      
      def do_sys mesg
        address = mesg.address
        address['/sys/'] = ''
        params = mesg.to_a
        case address
        when 'devices'
          #        puts "devices - #{params[0]}" #TODO implement device management
        when 'type'
          #TODO implement device management. for now only take from device 1
          if params[0] = 0
            @state.monome_type = params[1]
            @device_detected = true
            puts "found device: #{@state.monome_type}"
          end
        when 'prefix'
#          puts "unit #{params[0]} - prefix #{params[1]}" #TODO implement device management
        when 'cable'
#          puts "unit #{params[0]} - cable #{params[1]}" #TODO implement device management
        when 'offset'
#          puts "unit #{params[0]} - offset x#{params[1]} y#{params[2]}" #TODO implement device management
        end
      end
      
      def draw_naeu
        lr_0 = 0b11111111
        lr_1 = 0b11100000
        lr_2 = 0b11101111
        lr_3 = 0b11111000
        lr_4 = 0b11111000
        lr_5 = 0b11101111
        lr_6 = 0b11100000
        lr_7 = 0b11111111
        rr_0 = 0b11111111
        rr_1 = 0b00000111
        rr_2 = 0b11110111
        rr_3 = 0b00011111
        rr_4 = 0b00011111
        rr_5 = 0b11110111
        rr_6 = 0b00000111
        rr_7 = 0b11111111
        
        send_frame(8,0, lr_0, lr_1, lr_2, lr_3, lr_4, lr_5, lr_6, lr_7)
        send_frame(0,0, rr_0, rr_1, rr_2, rr_3, rr_4, rr_5, rr_6, rr_7)
      end
      
      def draw_inverted_naeu
        lr_0_i = 0b00000000
        lr_1_i = 0b00011111
        lr_2_i = 0b00010000
        lr_3_i = 0b00000111
        lr_4_i = 0b00000111
        lr_5_i = 0b00010000
        lr_6_i = 0b00011111
        lr_7_i = 0b00000000
        rr_0_i = 0b00000000
        rr_1_i = 0b11111000
        rr_2_i = 0b00001000
        rr_3_i = 0b11100000
        rr_4_i = 0b11100000
        rr_5_i = 0b00001000
        rr_6_i = 0b11111000
        rr_7_i = 0b00000000
        
        send_frame(8,0, lr_0_i, lr_1_i, lr_2_i, lr_3_i, lr_4_i, lr_5_i, lr_6_i, lr_7_i)
        send_frame(0,0, rr_0_i, rr_1_i, rr_2_i, rr_3_i, rr_4_i, rr_5_i, rr_6_i, rr_7_i)
      end
    end
  end
end

