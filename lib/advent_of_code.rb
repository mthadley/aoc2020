require "optparse"

class AdventOfCode
  autoload :Day, "advent_of_code/day"

  def self.play
    new(Options.parse!).play
  end

  def initialize(options)
    @options = options
  end

  def play
    for_day(@options.day)
  end

  def for_day(day_num)
    begin
      require_relative "advent_of_code/day#{day_num}"
    rescue LoadError
      $stderr.puts "Error: Solution does not exist for day #{day_num}."
      exit 1
    end

    day = self.class.const_get("Day#{day_num}").new

    puts <<~OUT
      Day ##{day_num}
      =========================
      Part 1: #{get_answer(day, :part1)}
      Part 2: #{get_answer(day, :part2)}
    OUT
  end

  private

  def get_answer(day, part)
    day.send(part) || "N/A"
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
