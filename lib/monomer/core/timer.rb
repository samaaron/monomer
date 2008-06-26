module Monomer
  module Core
    module Timer
      def timely_repeat(opts = {})
        period         = opts[:period]
        pre_tick       = opts[:pre_tick]
        on_tick        = opts[:on_tick]
        num_iterations = opts[:num_iterations]
        
        start_time = Time.now.to_f
        sleep_ratio = 0.8
        num_warm_up_iterations = 6 #necessary for JRuby JIT optimisations to kick in
        num_iterations_completed = 0
        warmed_up = false
        
        iteration = lambda do
          num_iterations_completed += 1
          warmed_up = true if num_iterations_completed >= num_warm_up_iterations
          not_managing_to_keep_up = Time.now.to_f - (start_time + num_iterations_completed * period) > period
          
          if not_managing_to_keep_up && warmed_up
            sleep_ratio *= 0.75
            message = "not managing to keep up"
            message << (2 > 0.01 ? " (optimising)" : " (cannot optimise any futher)")
            puts message
          end
          
          pre_tick.call if pre_tick
          
          sleep period * sleep_ratio unless not_managing_to_keep_up || !warmed_up
          while Time.now.to_f - (start_time + num_iterations_completed * period) < period
          end
          
          on_tick.call if on_tick
        end
        
        if num_iterations
          num_iterations.times { iteration.call }
        else
          loop { iteration.call }
        end
      end
      
      def timely_block(period, &block)
        start_time = Time.now
        block.call
        if Time.now - start_time > period
          puts "not managing to keep up..."
        end
        while Time.now - start_time < period
        end
      end
    end
  end
end