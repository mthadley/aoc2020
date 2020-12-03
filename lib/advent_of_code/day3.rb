class AdventOfCode
  class Day3 < Day
    has_input_file

    def part1
      count_trees(step: Point.new(3, 1))
    end

    def part2
      steps = [
        Point.new(1, 1),
        Point.new(3, 1),
        Point.new(5, 1),
        Point.new(7, 1),
        Point.new(1, 2)
      ]

      steps.
        map { |step| count_trees(step: step) }.
        reduce(:*)
    end

    private

    def count_trees(step:)
      location = Point.origin
      total_trees = 0

      while at_location = map.at(location)
        total_trees += 1 if at_location == :tree
        location += step
      end

      total_trees
    end

    def map
      @map ||=
        begin
          map = Map.new
          input.each { |line| map.add_row(line) }
          map
        end
    end

    class Map
      attr_reader :grid

      def initialize
        @grid = []
        @width = 0
      end

      def add_row(string)
        new_row =
          string.chars.map do |char|
            case char
            when "." then :open
            when "#" then :tree
            end
          end

        @width = [@width, new_row.size].max
        @grid << new_row
      end

      def at(point)
        grid[point.y]&.send(:[], point.x % @width)
      end
    end
  end
end