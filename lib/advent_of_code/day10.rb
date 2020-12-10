module AdventOfCode
  class Day10 < Day
    input_file do |lines|
      lines.map { |line| line.to_i }
    end

    part1 answer: 2346 do
      diff_counts = joltage_diffs.tally

      diff_counts[1] * diff_counts[3]
    end

    part2 answer: 6044831973376 do
      combinations = 1
      in_a_row = 0

      joltage_diffs.each.with_index do |diff, i|
        if [diff, joltage_diffs[i - 1]] == [1, 1]
          in_a_row += 1
        else
          # Number of possibilities based on the group size. According to the
          # internet it's the tribonacci sequence, but I don't know much about
          # that or how to calculate it.
          combinations *=
            case in_a_row
            when 0 then 1
            when 1 then 2
            when 2 then 4
            when 3 then 7
            else
              fail "I don't know what the next value would be."
            end

          in_a_row = 0
        end
      end

      combinations
    end

    private

    def joltage_diffs
      @joltage_diffs ||=
        begin
          joltages = (input + [0, input.max + 3]).sort

          joltages.sort.filter_map.with_index do |j, i|
            next if i.zero?

            j - joltages[i - 1]
          end
        end
    end
  end
end
