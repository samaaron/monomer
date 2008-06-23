module Monomer
  module Core
    class LED
      def initialize
        @on_stack = []
      end
      
      def turn_on(thread)
        return false if @on_stack.include? thread
        @on_stack << thread
        @on_stack.size == 1 ? true : false
      end
      
      def turn_off(thread)
        @on_stack.delete thread
        @on_stack.empty? ? true : false
      end
      
      def toggle(thread)
        if @on_stack.include?(thread)
          return turn_off(thread) ? :off : nil
        else
          return turn_on(thread) ? :on : nil
        end
      end
    end
  end
end