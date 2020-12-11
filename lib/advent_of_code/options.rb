module AdventOfCode
  class Options
    attr_accessor :day, :run_slow

    def self.parse!
      new.parse!
    end

    def parse!
      OptionParser.new do |opts|
        day_option(opts)
        slow_option(opts)
      end.parse!

      self
    end

    alias_method :run_slow?, :run_slow

    private

    def day_option(opts)
      opts.on("-d DAY", "--day DAY", Integer, "The day to play") do |day|
        self.day = day
      end
    end

    def slow_option(opts)
      opts.on("-s", "--run_slow", "Don't skip slow days") do |run_slow|
        self.run_slow = run_slow
      end
    end
  end
end
