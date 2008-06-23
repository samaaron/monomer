module Monomer
  module Core
    class LED
      def initialize
        @on_stack = []
      end
      
      def turn_on(thread_name)
        return false if @on_stack.include? thread_name
        @on_stack << thread_name
        @on_stack.size == 1 ? true : false
      end
      
      def turn_off(thread_name)
        @on_stack.delete thread_name
        @on_stack.empty? ? true : false
      end
      
      def toggle(thread_name)
        if @on_stack.include?(thread_name)
          return turn_off(thread_name) ? :off : nil
        else
          return turn_on(thread_name) ? :on : nil
        end
      end
    end
  end
end