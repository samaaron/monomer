module Monomer
  class Listener
    def self.monome
      Monome.monome
    end
    
    def self.timely_repeat(repeat_time, num_times, &block)
      t = Time.now
      sleep_ratio = 0.9
      num_warm_up_iterations = 6 #necessary for JRuby JIT optimisations to kick in
      num_iterations = 0
      warmed_up = false
      num_times.times do
        num_iterations += 1 unless warmed_up
        warmed_up = true if num_iterations >= num_warm_up_iterations
        not_managing_to_keep_up = Time.now - t > repeat_time
        if not_managing_to_keep_up && warmed_up
          puts "not managing to keep up..."
          sleep_ratio *= 0.75
        end
        sleep repeat_time * sleep_ratio unless not_managing_to_keep_up || !warmed_up
        while Time.now - t < repeat_time
        end
        t = Time.now
        block.call
      end
    end
    
    def self.timely_block(repeat_time, &block)
      t = Time.now
      block.call
      if Time.now - t > repeat_time
        puts "not managing to keep up..."
      end
      while Time.now - t < repeat_time
      end
    end
    
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
    
    def self.on_key_down(&block)
      meta_def :button_pressed do |x,y|
        Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          block.call(x,y)
        end
      end
    end
    
    def self.on_key_up(&block)
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