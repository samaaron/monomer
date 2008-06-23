module Monomer
  module Core
    class Lights
      def initialize(max_x, max_y)
        @leds = {}
      end
      
      def turn_on(x, y, thread)
        led(x,y).turn_on(thread)
      end
      
      def turn_off(x, y, thread)
        led(x,y).turn_off(thread)
      end
      
      def toggle(x, y, thread)
        led(x,y).toggle(thread)
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