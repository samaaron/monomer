module Monomer
  module Core
    class Message
      attr_reader :id, :message, :time, :x, :y
      def initialize(id, message, time, x=nil, y=nil)
        @id = id
        @message = message
        @time = time
        @x = x
        @y = y
      end
      
      def to_s
        "id: #{id}, message: #{@message}, x: #{x}, y: #{y}"
      end
    end
  end
end

