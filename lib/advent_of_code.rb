require "optparse"

class AdventOfCode
  autoload :Day, "advent_of_code/day"
  autoload :Point, "advent_of_code/point"

  def self.play
    new(Options.parse!).play
  end

  def initialize(options)
    @options = options
  end

  def play
    if @options.day
      puts for_day(@options.day)
    else
      puts all_days.map { |day| for_day(day) }.join("\n")
    end
  end

  def all_days
    @all_days ||=
      Dir.children(File.expand_path("advent_of_code", __dir__)).
        map do |name|
          if /day(?<day_num>\d+)\.rb$/ =~ name
            day_num.to_i
          end
        end.
        compact.
        sort
  end

  def for_day(day_num)
    day = load_day_class(day_num)

    <<~OUT
      Day ##{day_num}
      =========================
      Part 1: #{get_answer(day, :part1)}
      Part 2: #{get_answer(day, :part2)}
    OUT
  end

  private

  def load_day_class(day_num)
    begin
      path = "advent_of_code/day#{day_num}"
      require_relative path
    rescue LoadError => e
      raise unless e.path.end_with?(path)

      $stderr.puts "Error: Solution does not exist for day #{day_num}."
      exit 1
    end

    self.class.const_get("Day#{day_num}").new
  end

  def get_answer(day, part)
    result = day.send(part)

    if result.answer.nil?
      "N/A"
    else
      format_answer(result)
    end
  end

  def format_answer(result)
    correctness_sym =
      case result.correct?
      when nil then "❔"
      when false then "❌"
      when true then "✅"
      end

    "#{result.answer} #{correctness_sym}"
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
