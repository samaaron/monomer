module Monome
  module Listeners
    class CornerToggles
      attr_accessor :monome
      
      def initialize(required_number_of_consecutive_taps=4)
        @required_number_of_consecutive_taps = required_number_of_consecutive_taps - 1
        @number_of_consecutive_taps = 0
        @last_key = []
      end
      
      def button_pressed(x,y)
        if @last_key == [x,y]
          @number_of_consecutive_taps += 1
          
          if (x == 0 && y == 0)
              @monome.clear if tapped_enough?
          elsif (x == @monome.max_x && y == @monome.max_y)
              @monome.all if tapped_enough?
          end
          
        else
          @number_of_consecutive_taps = 0
        end
        
        @last_key = [x,y]
       
      end
      
      def tapped_enough?
        @number_of_consecutive_taps == @required_number_of_consecutive_taps
      end
    end
  end
end