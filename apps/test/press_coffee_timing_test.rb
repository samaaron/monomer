#!/usr/bin/env jruby -wKUd

#need to make sure that the statarray lib is available, and also edit the listener to support num_iterations for timely_repeat

#results:

# with sleep
# {:sum=>156.65100000000018,
#  :mean=>0.15665100000000018,
#  :stddev=>0.00917842265546986,
#  :min=>0.145,
#  :max=>0.334,
#  :median=>0.155,
#  :count=>1000}
# timely block with just update patterns
# {:sum=>166.29400000000027,
#  :mean=>0.16629400000000027,
#  :stddev=>0.025912565002813286,
#  :min=>0.14200000000000002,
#  :max=>0.406,
#  :median=>0.158,
#  :count=>1000}
# all in one timely block
# {:sum=>141.85500000000025,
#  :mean=>0.14185500000000026,
#  :stddev=>0.029510283492908546,
#  :min=>0.02,
#  :max=>0.312,
#  :median=>0.14100000000000001,
#  :count=>1000}
# timely repeat
# {:sum=>144.28400000000033,
#  :mean=>0.14428400000000033,
#  :stddev=>0.007895675125388952,
#  :min=>0.124,
#  :max=>0.246,
#  :median=>0.14300000000000002,
#  :count=>1000}

require 'pp'
require '/Library/Ruby/Gems/1.8/gems/statarray-0.0.1/lib/statarray'
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
    @time = Time.now
    @times_a = [].to_statarray
    @times_b = [].to_statarray
    @times_c = [].to_statarray
    @times_d = [].to_statarray
  end
  
  on_start do
    monome.spawn do
      loop do
        x = monome.rand_x
        y = monome.rand_y
        @current_patterns[x] = y
        @step_offsets[x] = @current_offset
      end
    end
    
    monome.spawn do
      loop do
        x = monome.rand_x
        @current_patterns[x] = -1
      end
    end
    
    @time = Time.now
    20.times do
      sleep 0.14
      update_patterns
      send_midi_and_light_monome
    end
    
    @time = Time.now
    1000.times do
      sleep(0.14)
        update_patterns
      send_midi_and_light_monome
      diff = Time.now - @time
      #puts diff
      @times_a << diff
      @time = Time.now
    end
    
    @time = Time.now
    1000.times do
      timely_block(0.14) do
        update_patterns
      end
      send_midi_and_light_monome
      diff = Time.now - @time
      #puts diff
      @times_b << diff
      @time = Time.now
    end
    
    @time = Time.now
    1000.times do
      timely_block(0.14) do
        update_patterns
        send_midi_and_light_monome
        diff = Time.now - @time
        #puts diff
        @times_c << diff
        @time = Time.now
      end
    end
    
    @time = Time.now
    timely_repeat(0.14, 1000) do
      update_patterns
      send_midi_and_light_monome
      diff = Time.now - @time
      #puts diff
      @times_d << diff
      @time = Time.now
    end
    
    
puts "with sleep"
    pp @times_a
    puts "timely block with just update patterns"
    
     pp @times_b
     puts "all in one timely block"
     
     pp @times_c
     puts "timely repeat"
     
     pp @times_d
    
  puts "with sleep"
  pp @times_a.to_stats
  puts "timely block with just update patterns"
  pp @times_b.to_stats
  puts "all in one timely block"
  pp @times_c.to_stats
  puts "timely repeat"
  pp @times_d.to_stats
 
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