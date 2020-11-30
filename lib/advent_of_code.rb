require "optparse"

class AdventOfCode
  def self.play
    new(Options.parse!).play
  end

  def initialize(options)
    @options = options
  end

  def play
    for_day(@options.day)
  end

  def for_day(day)
    begin
      require_relative "advent_of_code/day#{day}"
    rescue LoadError
      $stderr.puts "Error: Solution does not exist for day #{day}."
      exit 1
    end

    day = self.class.const_get("Day#{day}")
    day = day.new

    puts <<~OUT
      Part 1: #{day.part1}
      Part 2: #{day.part2}
    OUT
  end

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
