class AdventOfCode::Day1
  TARGET = 2020
  def part1
    sum_map = input.each_with_object({}) do |n, map|
      map[TARGET - n] = n
    end

    first = input.find { |n| sum_map.has_key?(n) }
    second = sum_map[first]

    first * second
  end

  def part2
  end

  private

  def input
    @input ||= File.readlines("input/day1.txt").map(&:to_i)
  end
end
