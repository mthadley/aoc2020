class AdventOfCode::Day1
  TARGET = 2020
  def part1
    find_two_sum(TARGET).inject(:*)
  end

  def part2
    input.each do |n|
      possible_nums = find_two_sum(TARGET - n)

      if possible_nums
        return [n, *possible_nums].inject(:*)
      end
    end

    -1
  end

  private

  def find_two_sum(target)
    sum_map = build_sum_map(target)

    first = input.find { |n| sum_map.has_key?(n) }
    second = sum_map[first]

    result = [first, second]
    result if result.all?
  end

  def build_sum_map(target)
    input.each_with_object({}) do |n, map|
      map[target - n] = n
    end
  end

  def input
    @input ||= File.readlines("input/day1.txt").map(&:to_i)
  end
end
