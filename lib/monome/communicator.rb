require 'gopt'
require 'osc'
module Monome
  class Communicator    
    attr_accessor :listeners
    attr_reader :max_x, :max_y, :led_status
    
    def initialize(monome=128, in_port=8000, out_port=8080)
      @monome = monome
      @client = OSC::SimpleClient.new('localhost', out_port)
      @server = OSC::SimpleServer.new(in_port)
      @max_x, @max_y = find_max_coords_from_monome_type
      #clear
      @led_toggle_status = Hash.new(false)  
      @listeners = []
    end
    
    def ascii_status(join_string="\n")
      result = ""
      (0..@max_y).each{|y| result << (0..@max_x).map{|x| @led_toggle_status[[x,y]] ? '* ' : '- '}.join + join_string}
      result
    end
    
    def led_on(x,y)
      @led_toggle_status[[x,y]] = true
      @client.send(OSC::Message.new('/test/led', nil, x,y, 1))
    end
    
    def led_off(x,y)
      @led_toggle_status[[x,y]] = false
      @client.send(OSC::Message.new('/test/led', nil, x,y, 0))
    end
    
    def toggle_led(x,y)
      @led_toggle_status[[x,y]] = !@led_toggle_status[[x,y]]
      @led_toggle_status[[x,y]] ? led_on(x,y) : led_off(x,y)
    end
    
    def clear
      (0..@max_x).each{|x| (0..@max_y).each{|y| led_off(x,y)}}
    end
    
    def all
      (0..@max_x).each{|x| (0..@max_y).each{|y| led_on(x,y)}}
    end
    
    def run
      register_self_with_listeners
      @server.add_method(nil) do |mesg|
        x,y =  mesg.to_a[0..1]
        if mesg.to_a[2] == 1 
          @listeners.each {|listener| listener.button_pressed(x,y) if listener.respond_to? :button_pressed}
        else
          @listeners.each {|listener| listener.button_released(x,y) if listener.respond_to? :button_released}
        end
      end
      @server.run
    end
    
    private
    
    def register_self_with_listeners
      @listeners.each {|listener| listener.monome = self if listener.respond_to? :monome=}
    end
    
    def find_max_coords_from_monome_type
      case @monome
      when 128
        return [15,7]
      end
    end
  end
end

