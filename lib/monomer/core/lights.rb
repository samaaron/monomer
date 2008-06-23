module Monomer
  module Core
    class Lights
      def initialize(max_x, max_y)
        @leds = {}
      end
      
      def turn_on(x, y, thread_name)
        led(x,y).turn_on(thread_name)
      end
      
      def turn_off(x, y, thread_name)
        led(x,y).turn_off(thread_name)
      end
      
      def toggle(x, y, thread_name)
        led(x,y).toggle(thread_name)
      end
      
      def clear
        @leds = {}
      end
      
      def all
        @leds = {}
      end
      
      def status(x,y)
        @leds[[x,y]]
      end
      
      def led(x, y)
        @leds[[x,y]] ||= LED.new
      end
      
    end
  end
end