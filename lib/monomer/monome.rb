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
      @loop_on_start_listeners = []
      @key_sustain_listeners = []
      @before_start_listeners = []
      @specific_button_pressed_listeners = []
      @specific_button_released_listeners = []
      @specific_button_sustain_listeners = []
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
    
    def col_size
      @state.max_y + 1
    end
    
    def row_size
      @state.max_x + 1
    end
    
    alias :num_cols :row_size
    alias :num_rows :col_size
    
    def rand_x
      rand(@state.max_x + 1)
    end
    
    def rand_y
      rand(@state.max_y + 1)
    end
    
    alias :rand_col_button :rand_y 
    alias :rand_row_button :rand_x 
    alias :rand_col_led    :rand_y 
    alias :rand_row_led    :rand_x
    
    def column_indices
      (0..max_x).to_a
    end
    
    def row_indices
      (0..max_y).to_a
    end
    
    alias :column_indexes :column_indices
    alias :row_indexes :row_indices
    
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
      col_light_pattern = (0..max_y).map{|y|led_off(col,y)}.map{|need_to_turn_off| need_to_turn_off ? 0 : 1}
      light_column(col, col_light_pattern)
    end
    
    def light_column(col, pattern)
      @communicator.light_column(col, *pattern)
    end
    
    def light_row(row, pattern)
      @communicator.light_row(row, *pattern)
    end
    
    def clear
      @communicator.clear
    end
    
    def all
      @communicator.all
    end
    
    def button_pressed(x,y)
      @button_pressed_listeners.each {|listener| listener.listen_for_button_pressed(x,y)}
      @specific_button_pressed_listeners.each do |listener|
        listener.send("listen_for_button_pressed_#{x}_#{y}", x, y) if listener.respond_to? "listen_for_button_pressed_#{x}_#{y}"
        listener.send("listen_for_button_pressed_#{x}_any", x, y)  if listener.respond_to? "listen_for_button_pressed_#{x}_any"
        listener.send("listen_for_button_pressed_any_#{y}", x, y)  if listener.respond_to? "listen_for_button_pressed_any_#{y}"
      end
      
      @key_sustain_listeners.each    {|listener| listener.listen_for_button_sustain_on(x,y)}
      @specific_button_sustain_listeners.each do |listener|
        listener.send("listen_for_button_sustain_on_#{x}_#{y}", x, y) if listener.respond_to? "listen_for_button_sustain_on_#{x}_#{y}"
        listener.send("listen_for_button_sustain_on_#{x}_any", x, y)  if listener.respond_to? "listen_for_button_sustain_on_#{x}_any"
        listener.send("listen_for_button_sustain_on_any_#{y}", x, y)  if listener.respond_to? "listen_for_button_sustain_on_any_#{y}"
      end
    end
    
    def button_released(x,y)
      @button_released_listeners.each {|listener| listener.listen_for_button_released(x,y)}
      @specific_button_released_listeners.each do |listener|
        listener.send("listen_for_button_released_#{x}_#{y}", x, y) if listener.respond_to? "listen_for_button_released_#{x}_#{y}"
        listener.send("listen_for_button_released_#{x}_any", x, y)  if listener.respond_to? "listen_for_button_released_#{x}_any"
        listener.send("listen_for_button_released_any_#{y}", x, y)  if listener.respond_to? "listen_for_button_released_any_#{y}"
      end
      
      @key_sustain_listeners.each {|listener| listener.listen_for_button_sustain_off(x,y)}
      @specific_button_sustain_listeners.each do |listener|
        listener.send("listen_for_button_sustain_off_#{x}_#{y}", x, y) if listener.respond_to? "listen_for_button_sustain_off_#{x}_#{y}"
        listener.send("listen_for_button_sustain_off_#{x}_any", x, y)  if listener.respond_to? "listen_for_button_sustain_off_#{x}_any"
        listener.send("listen_for_button_sustain_off_any_#{y}", x, y)  if listener.respond_to? "listen_for_button_sustain_off_any_#{y}"
      end
    end
    
    def start
      register_self_with_listeners
      determine_listener_hooks
      @before_start_listeners.each {|listener| listener.listen_for_before_start}
      @communicator.start do
        @on_start_listeners.each {|listener| listener.listen_for_start}
        @loop_on_start_listeners.each {|listener| listener.listen_for_loop_on_start}
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
        @button_released_listeners  << listener if listener.respond_to? :listen_for_button_released
        @button_pressed_listeners   << listener if listener.respond_to? :listen_for_button_pressed
        @on_start_listeners         << listener if listener.respond_to? :listen_for_start
        @loop_on_start_listeners    << listener if listener.respond_to? :listen_for_loop_on_start
        @key_sustain_listeners      << listener if listener.respond_to? :listen_for_button_sustain_on
        @before_start_listeners     << listener if listener.respond_to? :listen_for_before_start
        
        @specific_button_pressed_listeners  << listener if listener.methods.grep(/\Alisten_for_button_pressed_/)
        @specific_button_released_listeners << listener if listener.methods.grep(/\Alisten_for_button_released_/)
        @specific_button_sustain_listeners     << listener if listener.methods.grep(/\Alisten_for_button_sustain_on_/)
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

