module Monome
  class Monome    
    attr_accessor :listeners
    
    def initialize(monome=128, in_port=8000, out_port=8080)
      @monome = monome
      @state = State.new
      @communicator = Communicator.new(self, @state, in_port, out_port)
      @listeners = []
      clear
    end
    
    def max_y
      @state.max_y
    end
    
    def max_x
      @state.max_x
    end
    
    def ascii_status(join_string="\n")
      @state.ascii_status(join_string)
    end
    
    def led_on(x,y)
      @communicator.led_on(x,y)
    end
    
    def led_off(x,y)
      @communicator.led_off(x,y)
    end
    
    def toggle_led(x,y)
      @state.led_status(x,y) ? led_off(x,y) : led_on(x,y)
    end
    
    def clear
      (0..max_x).each{|x| (0..max_y).each{|y| led_off(x,y)}}
    end
    
    def all
      (0..max_x).each{|x| (0..max_y).each{|y| led_on(x,y)}}
    end
    
    def button_pressed(x,y)
      @listeners.each {|listener| listener.button_pressed(x,y) if listener.respond_to? :button_pressed}
    end
    
    def button_released(x,y)
      @listeners.each {|listener| listener.button_released(x,y) if listener.respond_to? :button_released}
    end
    
    def start
      register_self_with_listeners
      @communicator.start
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

