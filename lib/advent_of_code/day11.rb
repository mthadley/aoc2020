# frozen_string_literal: true

module AdventOfCode
  class Day11 < Day
    slow!

    has_input_file

    part1 answer: 2273 do
      final_occupied(:next_circular)
    end

    part2 answer: 2064 do
      final_occupied(:next_by_sight)
    end

    private

    def final_occupied(next_method)
      old_grid = nil
      grid = SeatMap.parse(input)

      while old_grid != grid
        old_grid = grid
        grid = old_grid.public_send(next_method)
      end

      grid.occupied
    end

    class SeatMap
      attr_reader :grid

      def self.parse(lines)
        grid = lines.map { |line| line.chars }

        new(grid)
      end

      def initialize(grid)
        @grid = grid.dup.map(&:dup)
      end

      def next_circular
        next_map(by: :occupied_around, threshold: 4)
      end

      def next_by_sight
        next_map(by: :occupied_around_by_sight, threshold: 5)
      end

      def occupied
        @grid.flatten.count("#")
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        grid == other.grid
      end

      def []=(point, value)
        @grid[point.y][point.x] = value
      end

      def [](point)
        return nil if point.x.negative?
        return nil if point.y.negative?

        @grid[point.y]&.at(point.x)
      end

      private

      def next_map(by:, threshold:)
        next_grid = self.class.new(@grid)

        each_cell do |cell, point|
          occupied_around = send(by, point)

          next_grid[point] =
            case
            when cell == "L" && occupied_around.zero?
              "#"
            when cell == "#" && occupied_around >= threshold
              "L"
            else
              cell
            end
        end

        next_grid
      end

      def each_cell(&block)
        @grid.each.with_index do |row, y|
          row.each.with_index do |value, x|
            block.call(value, Point.new(x, y))
          end
        end
      end

      def occupied_around(point)
        Point.cardinals.map { self[point + _1] }.count("#")
      end

      def occupied_around_by_sight(point)
        Point.cardinals.count do |dir|
          current = point + dir
          result = false

          while value = self[current]
            if value == "."
              current += dir
            elsif value == "#"
              result = true
              break
            elsif value == "L"
              result = false
              break
            end
          end

          result
        end
      end
    end
  end
end
