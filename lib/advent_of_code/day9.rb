module AdventOfCode
  class Day9 < Day
    PREAMBLE_SIZE = 25

    input_file do |lines|
      lines.map { |line| line.to_i }
    end

    part1 answer: 507622668 do
      (PREAMBLE_SIZE..input.size).each do |i|
        target = input[i]
        nums = input[(i - PREAMBLE_SIZE)..i]

        break target unless has_two_sum?(target, nums)
      end
    end

    part2 answer: 76688505 do
      target = part1.answer
      i = 0
      j = 1

      while i < input.size
        sum = input[i..j].sum

        case
        when sum == target
          break input[i..j].minmax.sum
        when sum < target
          j += 1
        when sum > target
          i += 1
          j = i + 1
        end
      end
    end

    private

    def has_two_sum?(target, nums)
      sum_map = nums.map { |n| [target - n, n] }.to_h

      first = nums.find { |n| sum_map.has_key?(n) }
      second = sum_map[first]

      result = [first, second]
      result if result.all?
    end
  end
end
