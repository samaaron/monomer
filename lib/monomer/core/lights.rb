module Monomer
  module Core
    class Lights
      def initialize(max_x, max_y)
        @leds = Hash.new(false)
      end
      
      def turn_on(x,y)
        @leds[[x, y]] = true
      end
      
      def turn_off(x,y)
        @leds[[x, y]] = false
      end
      
      def clear
        @leds = Hash.new(false)
      end
      
      def all
        @leds = Hash.new(true)
      end
      
      def status(x,y)
        @leds[[x,y]]
      end
    end
  end
end