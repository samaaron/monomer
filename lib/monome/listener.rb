module Monome
  class Listener
    def self.monome
      Monome.monome
    end
    
    def self.loop_on_key_sustain(&block)
      meta_def :loop_on_key_sustain do
        block
      end
    end
    
    def initialize
      @key_threads = {}
    end
    
    def button_pressed(x,y)
      @key_threads[[x,y]] = Thread.new do
        loop do
          self.class.loop_on_key_sustain.call
        end
      end
    end
    
    def button_released(x,y)
      if thread = @key_threads[[x,y]]
        thread.kill
        @key_threads[[x,y]] = nil
      end
    end
    
  end
end