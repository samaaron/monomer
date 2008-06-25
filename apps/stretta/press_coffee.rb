#!/usr/bin/env jruby -wKUd

#monomer version of Stretta's press cafe: http://stretta.blogspot.com/2007/11/press-cafe.html
require File.dirname(__FILE__) + '/../../lib/monomer'

class PressCoffee < Monomer::Listener
  
  before_start do
    @midi = Monomer::MidiOut.new
    @available_patterns = [
                           [0,0,0,0,0,0,0,1],
                           [0,0,1,0,0,1,0,0],
                           [1,1,0,0,1,1,0,0],
                           [1,1,1,0,0,0,1,1],
                           [0,0,0,1,1,1,0,0],
                           [1,0,0,1,1,1,0,1],
                           [0,1,0,1,1,1,0,0],
                           [1,1,1,1,1,1,1,1],
                          ]
                
    @current_patterns = [-1] * monome.row_size
    @step_offsets = [0] * monome.row_size
    @current_offset = 0
    @sleep = 0.14
    @patterns_to_play = []
  end
  
  on_start do
    timely_repeat(0.14) do
      update_patterns
      send_midi_and_light_monome
    end
  end
  
  on_key_down do |x,y|
    @current_patterns[x] = y
    @step_offsets[x] = @current_offset
  end
  
  on_key_up do |x,y|
    @current_patterns[x] = -1
  end
  
  def self.update_patterns
    @patterns_to_play = [nil] * monome.row_size
    @current_patterns.each_with_index do |pattern, index|
      if pattern != -1
        offset =  @step_offsets[index] - @current_offset
        current_pattern = @available_patterns[pattern].clone
        (offset % (monome.max_y + 1)).times do
          note = current_pattern.shift
          current_pattern.push(note)
        end
        @patterns_to_play[index] = current_pattern
      else
        monome.clear_column(index)
      end
    end
    
    @current_offset += 1
  end
  
  def self.send_midi_and_light_monome
    @patterns_to_play.each_with_index do |pattern, index|
      @midi.off(40 + index)
      
      if pattern
        monome.light_column(index, *pattern)
        @midi.on(40 + index) if pattern[monome.max_y] == 1
      end
      
    end
  end
end

Monomer::Monome.create.with_listeners(PressCoffee).start  if $0 == __FILE__