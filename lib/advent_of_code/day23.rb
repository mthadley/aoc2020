module AdventOfCode
  class Day23 < Day
    # INPUT = "389125467"
    INPUT = "853192647"

    part1 answer: "97624853" do
      cups = shuffle_cups(INPUT.chars.map(&:to_i))
      take_circular(cups, cups.size - 1, start: cups.index(1) + 1).join
    end

    private

    def shuffle_cups(cups)
      i = 0
      100.times do
        current = cups[i]

        selection = take_circular(cups, 3, start: i + 1)
        cups -= selection
        rest = take_circular(cups, cups.size - 1, start: i + 1).sort.reverse

        target = rest.find { _1 < current } || rest.max
        target_index = cups.index(target)

        cups = cups[0..target_index] + selection + cups[target_index + 1..-1]

        i = (cups.index(current) + 1) % cups.size
      end

      cups
    end

    def take_circular(arr, count, start: 0)
      count.times.map { |i| arr[(start + i) % arr.size] }
    end
  end
end
