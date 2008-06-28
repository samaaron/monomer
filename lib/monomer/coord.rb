module Monomer
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
end