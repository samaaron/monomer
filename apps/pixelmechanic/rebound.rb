#!/usr/bin/env jruby -wKUd

#monomer version of pixelmechanic's boiingg: http://docs.monome.org/doku.php?id=app:boiingg

require File.dirname(__FILE__) + '/../../lib/monomer'
class Rebound < Monomer::Listener
  
  before_start do
    @midi = Monomer::MidiOut.new
    @position  = [0] * monome.num_cols
    @direction = [0] * monome.num_cols
    @range     = [0] * monome.num_cols
    @current_column = 0
  end
  
  on_start do
    timely_repeat :bpm => 120, :prepare => L{bounce_lights_and_prepare_notes}, :on_tick => L{@midi.flush!}
  end
  
  on_any_button_press do |x,y|
    @range[x]     = y
    @position[x]  = y
    @direction[x] = 1
    monome.clear_column(x)
  end
  
  def self.bounce_lights_and_prepare_notes
    monome.column_indices.each do |col_index|
      @current_column = col_index
      when_bouncing do
        update_position
        prepare_note if reached_bottom?
        turn_off_led_for_previous_position
        turn_on_led_for_current_position
      end
    end
  end
  
  def self.prepare_note
    @midi.prepare_note(:duration => 0.5, :note => 40 + @current_column)
  end
  
  def self.when_bouncing
    yield if @range[@current_column] != 0
  end
  
  def self.turn_on_led_for_current_position
    monome.led_on(@current_column, @position[@current_column])
  end
  
  def self.turn_off_led_for_previous_position
    monome.led_off(@current_column, @position[@current_column] - @direction[@current_column])
  end
  
  def self.update_position
    reverse_direction if reached_bottom? || reached_top_of_range?
    @position[@current_column] += @direction[@current_column]
  end
  
  def self.reverse_direction
    @direction[@current_column] *= -1
  end
  
  def self.reached_bottom?
    @position[@current_column] == 0
  end
  
  def self.reached_top_of_range?
    @position[@current_column] == @range[@current_column]
  end
  
end

Monomer::Monome.create.with_listeners(Rebound).start  if $0 == __FILE__