module Monome
  class State    
    attr_reader :max_x, :max_y
    
    def initialize(monome=128)
      @monome = monome
      @max_x, @max_y = find_max_coords_from_monome_type
      @led_toggle_status = Hash.new(false)
      @messages = []
    end
    
    def notify(message)
      message = Message.new(@messages.size, message[:message], message[:time], message[:x], message[:y])
      puts message
      @messages << message
      if message.message == :button_pressed
        toggle_led_status(message.x, message.y)
      end
    end
    
    def ascii_status(join_string="\n")
      result = ""
      (0..@max_y).each{|y| result << (0..@max_x).map{|x| @led_toggle_status[[x,y]] ? '* ' : '- '}.join + join_string}
      result
    end
    
    def led_status(x,y)
      @led_toggle_status[[x,y]]
    end
        
    private
    
    def toggle_led_status(x,y)
      @led_toggle_status[[x,y]] = !@led_toggle_status[[x,y]]
    end
    
    def find_max_coords_from_monome_type
      case @monome
      when 128
        return [15,7]
      end
    end
  end
end

