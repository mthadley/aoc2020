class AdventOfCode
  class Day5 < Day
    input_file do |lines|
      lines.map { |line| Seat.parse(line) }
    end

    part1 answer: 888 do
      input.map(&:id).max
    end

    part2 answer: 522 do
      sorted_seats = input.sort_by(&:id)
      min = sorted_seats.first.id
      max = sorted_seats.last.id

      (min..max).zip(sorted_seats).each do |expected, seat|
        break seat.id - 1 if seat.id != expected
      end
    end

    class Seat
      def self.parse(string)
        row_s = string.chars.take(7)
        col_s = string.chars.drop(7)

        new(row_s, col_s)
      end

      def initialize(row_s, col_s)
        @row_s = row_s
        @col_s = col_s
      end

      def id
        row * 8 + col
      end

      def col
        to_binary(@col_s)
      end

      def row
        to_binary(@row_s)
      end

      private

      def to_binary(chars)
        chars.map do |c|
          case c
          when "B", "R" then 1
          when "F", "L" then 0
          end
        end.join.to_i(2)
      end
    end
  end
end
