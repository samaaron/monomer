module Monome
  module Listeners
    class Rectangles
      
      class Coord
        attr_accessor :x, :y
        def initialize(x,y)
          @x = x
          @y = y
        end
        
        def ==(other)
          other.x == @x
          other.y == @y
        end
        
        def hash
          @x * 10 + @y
        end
        
        alias_method :eql?, :==
      end
      
      attr_accessor :monome
      def initialize(required_number_of_consecutive_taps=4)
        @last_five_taps = [[0,0],[0,0],[0,0],[0,0],[0,0]]
      end
      
      def button_pressed(x,y)
        @last_five_taps.pop
        @last_five_taps.unshift([x,y])
        draw_rectangle if rectangle_combination_entered?
      end
      
      def rectangle_combination_entered?
        last_two_taps_are_duplicates? && first_four_taps_define_a_rectangle?
      end
      
      def last_two_taps_are_duplicates?
        @last_five_taps[0] == @last_five_taps[1]
      end
      
      def first_four_taps_define_a_rectangle?
        ordered_coords = order_first_four_taps_spatially
        
        ordered_coords.uniq.size == 4 &&
        (ordered_coords[0].x == ordered_coords[1].x) &&
        (ordered_coords[0].y == ordered_coords[2].y) &&
        (ordered_coords[2].x == ordered_coords[3].x) &&
        (ordered_coords[1].y == ordered_coords[3].y)
      end
      
      def order_first_four_taps_spatially
        last_four_taps = @last_five_taps[1..-1]
        last_four_taps.sort.map{|coords| Coord.new(coords[0],coords[1])}
      end
      
      def draw_rectangle
        ordered_coords = order_first_four_taps_spatially
        (ordered_coords[0].x..ordered_coords[2].x).each{|x| (ordered_coords[0].y..ordered_coords[1].y).each{|y| @monome.led_on(x, y)}}
      end
    end
  end
end