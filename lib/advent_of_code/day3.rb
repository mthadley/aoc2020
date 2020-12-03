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
        total_trees += 1 if at_location == "#"
        location += step
      end

      total_trees
    end

    def map
      @map ||=
        input.each_with_object(Map.new) do |line, map|
          map.add_row(line)
        end
    end

    class Map
      attr_reader :grid, :width

      def initialize
        @grid = []
        @width = 0
      end

      def add_row(string)
        new_row = string.chars

        @width = [width, new_row.size].max
        grid << new_row
      end

      def at(point)
        grid[point.y]&.at(point.x % width)
      end
    end
  end
end
