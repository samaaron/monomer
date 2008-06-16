module Monome
  class Monome
    
    class << self      
      def[](monome_type)
        raise "Unknown monome type" unless [64,128,256].include? monome_type
        @monome = Monome.new(monome_type)
        return @monome
      end
      
      def monome
        @monome
      end
    end
    
    attr_accessor :listeners
    
    def initialize(monome_type=128, prefix='/test', in_port=8000, out_port=8080)
      @state = State.new(monome_type)
      @communicator = Communicator.new(self, @state, prefix, in_port, out_port)
      @listeners = []
      @button_pressed_listeners = []
      @button_released_listeners = []
      clear
    end
    
    def with_listeners(*listeners)
      self.listeners = listeners.map {|listener| listener.new}
      self
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
      x,y = normalize(x,y)
      @communicator.led_on(x,y)
    end
    
    def led_off(x,y)
      x,y = normalize(x,y)
      @communicator.led_off(x,y)
    end
    
    def toggle_led(x,y)
      x,y = normalize(x,y)
      @state.led_status(x,y) ? led_off(x,y) : led_on(x,y)
    end
    
    def clear
      (0..max_x).each{|x| (0..max_y).each{|y| led_off(x,y)}}
    end
    
    def all
      (0..max_x).each{|x| (0..max_y).each{|y| led_on(x,y)}}
    end
    
    def button_pressed(x,y)
      x,y = normalize(x,y)
      @button_pressed_listeners.each {|listener| listener.button_pressed(x,y)}
    end
    
    def button_released(x,y)
      x,y = normalize(x,y)
      @button_released_listeners.each {|listener| listener.button_released(x,y)}
    end
    
    def start
      register_self_with_listeners
      determine_listener_hooks
      @communicator.start
    end
    
    def status
      @communicator.status
    end
    
    private
    
    def register_self_with_listeners
      @listeners.each {|listener| listener.monome = self if listener.respond_to? :monome=}
    end
    
    def determine_listener_hooks
      @listeners.each do |listener|
        @button_released_listeners  << listener if listener.respond_to? :button_released
        @button_pressed_listeners   << listener if listener.respond_to? :button_pressed
      end
    end
    
<<<<<<< HEAD:lib/monome/monome.rb
=======
    # make shure our coordinates are always valid.
    # lets ensure this in the monome class, as this is the interface used by the applications.
    def normalize(x,y)
      x = x % (max_x + 1)
      y = y % (max_y + 1)
      return x,y
    end
>>>>>>> 95a822d822bce06d6ab671b666f66cb36e78050d:lib/monome/monome.rb
  end
end

