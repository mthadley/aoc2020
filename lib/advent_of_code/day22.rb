require "set"

module AdventOfCode
  class Day22 < Day
    slow!

    has_input_file split_lines: false

    part1 answer: 32824 do
      deck1, deck2 = decks

      until [deck1, deck2].any?(&:empty?)
        top1, top2 = deck1.shift, deck2.shift

        if top1 > top2
          deck1 << top1 << top2
        else
          deck2 << top2 << top1
        end
      end

      score([deck1, deck2].find(&:any?))
    end

    part2 answer: 36515 do
      deck1, deck2 = decks

      deck1_winner, deck2_winner = recursive_combat(deck1, deck2)

      score(deck1_winner || deck2_winner)
    end

    private

    def recursive_combat(deck1, deck2, seen: Set.new)
      until [deck1, deck2].any?(&:empty?)
        return [deck1, nil] unless seen.add?([deck1, deck2].hash)

        top1, top2 = deck1.shift, deck2.shift

        winner =
          if deck1.size >= top1 && deck2.size >= top2
            deck1_winner, _ = recursive_combat(deck1.take(top1), deck2.take(top2))

            deck1_winner ? :deck1 : :deck2
          else
            top1 > top2 ? :deck1 : :deck2
          end

        case winner
        when :deck1 then deck1 << top1 << top2
        when :deck2 then deck2 << top2 << top1
        end
      end

      if deck1.empty?
        [nil, deck2]
      elsif deck2.empty?
        [deck1, nil]
      end
    end

    def score(deck)
      deck.reverse.map.with_index {  |c, i| c * (i + 1) }.sum
    end

    def decks
      input.split("\n\n").map do |chunk|
        chunk.lines(chomp: true).drop(1).map { |line| line.to_i }
      end
    end
  end
end
