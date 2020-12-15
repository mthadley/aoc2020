module AdventOfCode
  class Day15 < Day
    slow!

    INPUT = [1, 20, 8, 12, 0, 14].freeze

    part1 answer: 492 do
      num_for_turn(2020)
    end

    part2 answer: 63644 do
      num_for_turn(30000000)
    end

    private

    def num_for_turn(turn)
      game = Game.new(INPUT)
      game.next_turn! until game.turn == turn
      game.next_num
    end

    class Game
      attr_reader :turn

      def initialize(nums)
        @turn = 1
        @spoken = {}
        @last_num = nil

        nums.each { next_turn!(_1) }
      end

      def next_turn!(num = nil)
        @last_num = num || next_num
        update_spoken(@last_num)
        @turn += 1
      end

      def next_num
        if @spoken[@last_num].size == 1
          0
        else
          recent, second_recent = @spoken[@last_num].take(2)
          recent - second_recent
        end
      end

      private

      def update_spoken(num)
        @spoken[num] ||= []
        @spoken[num].unshift(@turn)
      end
    end
  end
end
