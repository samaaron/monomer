#!/usr/bin/env jruby -wKU

require File.dirname(__FILE__) + '/../../lib/monomer'

# a listener that listens for four rectangle corner presses (in any order) and the final corner being tapped twice. A
# filled rectangle is then displayed

class Rectangles < Monomer::Listener
  
  class Coord
    attr_accessor :x, :y
    def initialize(x,y)
      @x = x
      @y = y
    end
    
    def ==(other)
      (other.x == @x && other.y == @y)
    end
    
    def hash
      @x * 10 + @y
    end
    
    alias_method :eql?, :==
  end
  
  before_start do
    @last_five_taps = [[0,0],[0,0],[0,0],[0,0],[0,0]]
  end
  
  on_key_down do |x,y|
    @last_five_taps.pop
    @last_five_taps.unshift([x,y])
    draw_rectangle if rectangle_combination_entered?
  end
  
  def self.rectangle_combination_entered?
    last_two_taps_are_duplicates? && first_four_taps_define_a_rectangle?
  end
  
  def self.last_two_taps_are_duplicates?
    @last_five_taps[0] == @last_five_taps[1]
  end
  
  def self.first_four_taps_define_a_rectangle?
    ordered_coords = order_first_four_taps_spatially
    
    ordered_coords.uniq.size == 4 &&
    (ordered_coords[0].x == ordered_coords[1].x) &&
    (ordered_coords[0].y == ordered_coords[2].y) &&
    (ordered_coords[2].x == ordered_coords[3].x) &&
    (ordered_coords[1].y == ordered_coords[3].y)
  end
  
  def self.order_first_four_taps_spatially
    last_four_taps = @last_five_taps[1..-1]
    last_four_taps.sort.map{|coords| Coord.new(coords[0],coords[1])}
  end
  
  def self.draw_rectangle
    ordered_coords = order_first_four_taps_spatially
    (ordered_coords[0].x..ordered_coords[2].x).each{|x| (ordered_coords[0].y..ordered_coords[1].y).each{|y| monome.led_on(x, y)}}
  end
end

Monomer::Monome.create.with_listeners(Rectangles).start  if $0 == __FILE__