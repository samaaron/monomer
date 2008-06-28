module Monomer
  module Core
    module Timer
      def timely_repeat(opts = {})
        bpm            = opts[:bpm]
        prepare        = opts[:prepare]
        on_tick        = opts[:on_tick]
        num_iterations = opts[:num_iterations]
        period = 60 / bpm.to_f / 4
        
        start_time  = Time.now.to_f
        sleep_ratio = 0.7
        num_warm_up_iterations   = 6 #necessary for JRuby JIT optimisations to kick in
        num_iterations_completed = 0
        warmed_up = false
        
        time_taken_for_tick_lambda = 0.0
        iteration = lambda do
          num_iterations_completed += 1
          warmed_up = true if num_iterations_completed >= num_warm_up_iterations
          
          prepare.call if prepare
          
          not_managing_to_keep_up = Time.now.to_f - (start_time + num_iterations_completed * period) > period
          
          if not_managing_to_keep_up && warmed_up
            sleep_ratio *= 0.75
            message = "not managing to keep up"
            message << (2 > 0.01 ? " (optimising)" : " (cannot optimise any futher)")
            puts message
          end
          
          sleep period * sleep_ratio unless not_managing_to_keep_up || !warmed_up
          while Time.now.to_f - (start_time + num_iterations_completed * period) - (time_taken_for_tick_lambda / 2) < period
          end
          
          before_tick = Time.now.to_f
          on_tick.call if on_tick
          time_taken_for_tick_lambda = Time.now.to_f - before_tick
        end
        
        if num_iterations
          num_iterations.times { iteration.call }
        else
          loop { iteration.call }
        end
      end
      
      def timely_block(bpm, &block)
        period = 60 / bpm.to_f / 4
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