#!/usr/bin/env jruby -wKU
require File.dirname(__FILE__) + '/../../lib/monomer'

#press a corner 4 times to either clear or fill the monome with light

class CornerToggles < Monomer::Listener
  
  before_start do
    @required_number_of_consecutive_taps = 3
    @number_of_consecutive_taps = 0
    @last_key = []
  end
  
  on_any_button_press do |x,y|
    if @last_key == [x,y]
      @number_of_consecutive_taps += 1
      
      if (x == 0 && y == 0)
          monome.clear if tapped_enough?
      elsif (x == monome.max_x && y == monome.max_y)
          monome.all if tapped_enough?
      end
      
    else
      @number_of_consecutive_taps = 0
    end
    
    @last_key = [x,y]
   
  end
  
  def self.tapped_enough?
    @number_of_consecutive_taps == @required_number_of_consecutive_taps
  end
end

Monomer::Monome.create.with_listeners(CornerToggles).start  if $0 == __FILE__