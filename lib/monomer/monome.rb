module Monomer
  class Monome
    
    class << self      
      def create
        @monome = Monome.new
        return @monome
      end
      
      def monome
        @monome
      end
    end
    
    attr_accessor :listeners
    
    def initialize(monome_type='128', prefix='monomer', in_port=8000, out_port=8080)
      raise "Unknown monome type" unless ['40h', '64', '128', '256'].include? monome_type
      @state = Core::State.new(monome_type)
      @communicator = Core::Communicator.new(self, @state, monome_type, prefix, in_port, out_port)
      @listeners = []
      @button_pressed_listeners = []
      @button_released_listeners = []
      @on_start_listeners = []
      @key_sustain_listeners = []
      @before_start_listeners = []
      clear
    end
    
    def with_listeners(*listeners)
      self.listeners = listeners.map{|listener| listener.init}
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
      need_to_turn_led_on = @state.led_on(x,y, Thread.current.to_s)
      @communicator.led_on(x,y) if need_to_turn_led_on
    end
    
    def led_off(x,y)
      need_to_turn_led_off = @state.led_off(x,y, Thread.current.to_s)
      @communicator.led_off(x,y) if need_to_turn_led_off
    end
    
    def toggle_led(x,y)
      action = @state.toggle_led(x,y, Thread.current.to_s)
      case action
      when :on
        @communicator.led_on(x,y)
      when :off
        @communicator.led_off(x,y)
      end
    end
    
    def clear_column(col)
      light_column(col, 0,0,0,0,0,0,0,0)
    end
    
    def light_column(col, *pattern)
      @communicator.light_column(col, *pattern)
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
      register_self_with_listeners
      determine_listener_hooks
      @before_start_listeners.each {|listener| listener.before_start}
      @communicator.start do
        @on_start_listeners.each {|listener| listener.start}
      end      
    end
    
    def status
      @communicator.status
    end
    
    def spawn(&block)
      Thread.new do
        block.call
      end
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
        @before_start_listeners     << listener if listener.respond_to? :before_start
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

