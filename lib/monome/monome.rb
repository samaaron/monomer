module Monome
  class Monome
    
    class << self      
      def[](monome_type)
        monome_type = monome_type.to_s
        @monome = Monome.new(monome_type)
        return @monome
      end
      
      def monome
        @monome
      end
    end
    
    attr_accessor :listeners
    
    def initialize(monome_type='128', prefix='monomer', in_port=8000, out_port=8080)
      raise "Unknown monome type" unless ['40h', '64', '128', '256'].include? monome_type
      @state = State.new(monome_type)
      @communicator = Communicator.new(self, @state, monome_type, prefix, in_port, out_port)
      @listeners = []
      @button_pressed_listeners = []
      @button_released_listeners = []
      @on_start_listeners = []
      @key_sustain_listeners = []
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
      @communicator.clear
    end
    
    def all
      @communicator.all
    end
    
    def button_pressed(x,y)
      x,y = normalize(x,y)
      @button_pressed_listeners.each {|listener| listener.button_pressed(x,y)}
      @key_sustain_listeners.each    {|listener| listener.key_sustain_on(x,y)}
      
    end
    
    def button_released(x,y)
      x,y = normalize(x,y)
      @button_released_listeners.each {|listener| listener.button_released(x,y)}
      @key_sustain_listeners.each     {|listener| listener.key_sustain_off(x,y)}
    end
    
    def start
      puts 'starting'
      register_self_with_listeners
      determine_listener_hooks
      @communicator.start do
        @on_start_listeners.each {|listener| listener.start}
      end
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
        @on_start_listeners         << listener if listener.respond_to? :start
        @key_sustain_listeners      << listener if listener.respond_to? :key_sustain_on
      end
    end
    
    # make sure our coordinates are always valid.
    # lets ensure this in the monome class, as this is the interface used by the applications.
    def normalize(x,y)
      x = x % (max_x + 1)
      y = y % (max_y + 1)
      return x,y
    end
  end
end

