module Monome
  module Listeners
    class Toggle
      attr_accessor :monome
      
      def button_pressed(x,y)
         @monome.toggle_led(x,y)
      end
      
    end
  end
end