module Monomer
  module Core
    class State    
      attr_reader :max_x, :max_y, :monome_type
      
      def initialize(monome_type='128')
        @monome_type = monome_type
        @max_x, @max_y = find_max_coords_from_monome_type
        @lights = Lights.new(@max_x, @max_y)
        @num_messages = 0
      end
      
      def led_on(x, y, thread_name)
        @lights.turn_on(x, y, thread_name)
      end
      
      def led_off(x, y, thread_name)
        @lights.turn_off(x, y, thread_name)
      end
      
      def toggle_led(x, y, thread_name)
        @lights.toggle(x, y, thread_name)
      end
      
      def notify(message)
        message = Message.new(@num_messages, message[:message], message[:time], message[:x], message[:y])
        case message.message
        when :led_off
          #@lights.turn_off(message.x, message.y)
        when :led_on
         # @lights.turn_on(message.x, message.y)
        when :clear
          @lights.clear
        when :all
          @lights.all
        end
        @num_messages += 1
      end
      
      def ascii_status(join_string="\n")
        result = ""
        (0..@max_y).each{|y| result << (0..@max_x).map{|x| @lights.status(x,y) ? '* ' : '- '}.join + join_string}
        result
      end
      
      def led_status(x,y)
        @lights.status(x,y)
      end
      
      def monome_type=(type)
        raise 'illegal type' unless ['40h', '64', '128', '256'].include? type
        @monome_type = type
        @max_x, @max_y = find_max_coords_from_monome_type
      end
          
      private
      
      def find_max_coords_from_monome_type
        case @monome_type
        when '128'
          return [15,7]
        when '64', '40h'
          return [7,7]
        when '256'
          return [15,15]
        end
      end
    end
  end
end

  