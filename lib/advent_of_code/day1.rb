class AdventOfCode
  class Day1 < Day
    TARGET = 2020

    input_file "day1.txt" do |lines|
      lines.map(&:to_i)
    end

    def part1
      find_two_sum(TARGET).inject(:*)
    end

    def part2
      input.each do |n|
        if possible_nums = find_two_sum(TARGET - n)
          return [n, *possible_nums].inject(:*)
        end
      end

      -1
    end

    private

    def find_two_sum(target)
      sum_map = input.map { |n| [target - n, n] }.to_h

      first = input.find { |n| sum_map.has_key?(n) }
      second = sum_map[first]

      result = [first, second]
      result if result.all?
    end
  end
end
