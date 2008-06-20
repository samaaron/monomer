module Monomer
  class Listener
    def self.monome
      Monome.monome
    end
    
    def self.loop_on_key_sustain(&block)
      meta_def :loop_on_key_sustain do
        block
      end
      
      define_method :key_sustain_on do |x,y|
        @key_threads[[x,y]] = Thread.new do
          loop do
            self.class.loop_on_key_sustain.call(x,y)
          end
        end
      end
      
      define_method :key_sustain_off do |x,y|
        if thread = @key_threads[[x,y]]
          thread.kill
          @key_threads[[x,y]] = nil
        end
      end
    end
    
    def self.before_start(&block)
      meta_def :before_start do
        block
      end
      
      define_method :before_start do
        self.class.before_start.call
      end
    end
    
    def self.on_start(&block)
      meta_def :on_start do
        block
      end
            
      define_method :start do
        thread = Thread.new do
          self.class.on_start.call
        end
      end
    end
    
    def self.on_key_down(&block)
      meta_def :on_key_down do
        block
      end

      define_method :button_pressed do |x,y|
        Thread.new do
          self.class.on_key_down.call(x,y)
        end
      end
      
    end
    
    def self.on_key_up(&block)
      meta_def :on_key_up do
        block
      end
      
      define_method :button_released do |x,y|
        Thread.new do
          self.class.on_key_up.call(x,y)
        end
      end
    end
    
    
    def initialize
      @key_threads = {}
    end
    
  end
end