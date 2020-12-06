require "optparse"

module AdventOfCode
  autoload :Day, "advent_of_code/day"
  autoload :Point, "advent_of_code/point"
  autoload :Options, "advent_of_code/options"

  def self.play!
    Runner.new(Options.parse!).play
  end

  class Runner
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
          filter_map do |name|
            if /day(?<day_num>\d+)\.rb$/ =~ name
              day_num.to_i
            end
          end.
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

      self.class.const_get("AdventOfCode::Day#{day_num}").new
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
  end
end
