module Monomer
  class Listener
    def self.monome
      Monome.monome
    end
    
    extend Core::Timer
    
    def self.loop_on_key_sustain(&block)
      meta_def :key_sustain_on do |x,y|
        @key_threads[[x,y]] = Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          loop do
            block.call(x,y)
          end
        end
      end
      
      meta_def :key_sustain_off do |x,y|
        if thread = @key_threads[[x,y]]
          thread.kill
          @key_threads[[x,y]] = nil
        end
      end
    end
    
    def self.before_start(&block)
      meta_def :before_start do
        block.call
      end
    end
    
    def self.on_start(&block)
      meta_def :start do
        thread = Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          block.call
        end
      end
    end
    
    def self.loop_on_start(&block)
      meta_def :loop_on_start do
        thread = Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          loop do
            block.call
          end
        end
      end
    end
    
    def self.on_any_button_press(&block)
      meta_def :button_pressed do |x,y|
        Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          block.call(x,y)
        end
      end
    end
    
    def self.on_any_button_release(&block)
      meta_def :button_released do |x,y|
        Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          block.call(x,y)
        end
      end
    end
    
    def self.init
      @key_threads = {}
      self  
    end
    
    def self.change_to_s_of_this_thread_to_map_to_calling_class
      current_thread = Thread.current
      method_def = <<-END
        def current_thread.to_s
          "Thread for #{self}"
        end
      END
      eval method_def
    end
    
  end
end