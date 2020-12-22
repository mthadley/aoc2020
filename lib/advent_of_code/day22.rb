module AdventOfCode
  class Day22 < Day
    has_input_file split_lines: false

    part1 answer: 32824 do
      deck1, deck2 = decks

      until deck1.empty? || deck2.empty?
        top1, top2 = deck1.shift, deck2.shift

        if top1 > top2
          deck1 << top1 << top2
        else
          deck2 << top2 << top1
        end
      end

      winning_deck = [deck1, deck2].find(&:any?)
      winning_deck.reverse.map.with_index {  |c, i| c * (i + 1) }.sum
    end

    private

    def decks
      input.split("\n\n").map do |chunk|
        chunk.lines(chomp: true).drop(1).map { |line| line.to_i }
      end
    end
  end
end
