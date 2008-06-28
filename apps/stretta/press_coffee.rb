#!/usr/bin/env jruby -wKUd

#monomer version of Stretta's press cafe: http://stretta.blogspot.com/2007/11/press-cafe.html
require File.dirname(__FILE__) + '/../../lib/monomer'

class PressCoffee < Monomer::Listener
  
  before_start do
    @midi = Monomer::MidiOut.new
    @available_patterns = [
                           [0,0,0,0,0,0,0,1],
                           [0,1,0,1,0,1,0,1],
                           [0,0,1,1,0,0,1,1],
                           [0,0,0,0,1,1,1,1],
                           [0,0,0,1,1,1,0,0],
                           [1,0,0,1,1,1,0,1],
                           [0,1,0,1,1,1,0,0],
                           [1,1,1,1,1,1,1,1],
                          ]
                
    @current_patterns = [-1] * monome.row_size
    @step_offsets = [0] * monome.row_size
    @current_offset = 0
  end
  
  on_start do
    timely_repeat :bpm => 140, :prepare => L{update_patterns_and_lights}, :on_tick => L{@midi.play_prepared_notes!}
  end
  
  on_button_press do |x,y|
    @current_patterns[x] = y
    @step_offsets[x] = @current_offset
  end
  
  on_button_release do |x,y|
    @current_patterns[x] = -1
  end
  
  def self.update_patterns_and_lights
    patterns_to_play = [nil] * monome.row_size
    @current_patterns.each_with_index do |pattern, index|
      if pattern != -1
        offset =  @step_offsets[index] - @current_offset
        current_pattern = @available_patterns[pattern].clone
        (offset % (monome.max_y + 1)).times do
          note = current_pattern.shift
          current_pattern.push(note)
        end
        patterns_to_play[index] = current_pattern
      else
        monome.clear_column(index)
      end
    end
    
    @current_offset += 1
    patterns_to_play.each_with_index do |pattern, index|
      
      if pattern
        monome.light_column(index, *pattern)
        @midi.prepare_note(:duration => 0.5, :note => 40 + index) if pattern[monome.max_y] == 1
      end
      
    end
  end
  
end

Monomer::Monome.create.with_listeners(PressCoffee).start  if $0 == __FILE__