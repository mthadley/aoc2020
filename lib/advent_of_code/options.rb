class AdventOfCode
  class Options
    attr_accessor :day

    def self.parse!
      new.parse!
    end

    def parse!
      OptionParser.new do |opts|
        day_option(opts)
      end.parse!

      self
    end

    private

    def day_option(opts)
      opts.on("-d DAY", "--day DAY", Integer, "The day to play") do |day|
        self.day = day
      end
    end
  end
end
