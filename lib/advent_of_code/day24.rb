require "parslet"

module AdventOfCode
  class Day24 < Day
    slow!

    input_file do |lines|
      lines.map { |line| MovesParser.parse(line) }
    end
    alias_method :moves, :input

    part1 answer: 436 do
      TileSet.from_moves(moves).tiles.size
    end

    part2 answer: 4133 do
      tile_set = TileSet.from_moves(moves)
      100.times { tile_set = tile_set.succ }
      tile_set.tiles.size
    end

    private

    class TileSet
      attr_reader :tiles

      def self.from_moves(moves)
        new(initial_tiles(moves))
      end

      def self.dir_to_point(dir)
        case dir
        when :e  then Point.new(2, 0)
        when :se then Point.new(1, -1)
        when :sw then Point.new(-1, -1)
        when :w  then Point.new(-2, 0)
        when :nw then Point.new(-1,  1)
        when :ne then Point.new(1, 1)
        end
      end

      def self.all_dirs
        [:e, :se, :sw, :w, :nw, :ne].map { |dir| dir_to_point(dir) }
      end

      def self.initial_tiles(moves)
        initial_points(moves).each_with_object(Set.new) do |point, flipped|
          flipped.member?(point) ? flipped.delete(point) : flipped.add(point)
        end
      end

      def self.initial_points(moves)
        moves.map do |dirs|
          dirs.map { dir_to_point(_1) }.reduce(:+)
        end
      end

      def initialize(tiles)
        @tiles = tiles
      end

      def succ
        min_y, max_y = tiles.map(&:y).minmax
        min_x, max_x = tiles.map(&:x).minmax

        next_tiles = Set.new

        (min_y - 1..max_y + 1).each do |y|
          (min_x - 1..max_x + 1).each do |x|
            point = Point.new(x, y)
            black = tiles.member?(point)
            count_around = count_around(point)

            if black && !(count_around == 0 || count_around > 2)
              next_tiles.add(point)
            elsif !black && count_around == 2
              next_tiles.add(point)
            end
          end
        end

        self.class.new(next_tiles)
      end

      private

      def count_around(point)
        self.class.all_dirs.count { |dir_point| tiles.member?(point + dir_point) }
      end
    end

    class MovesParser < Parslet::Parser
      rule(:move) { (str("e") | str("se") | str("sw") | str("w") | str("nw") | str("ne")).as(:dir)  }
      rule(:moves) { move.repeat(1).as(:moves) }

      root(:moves)

      def self.parse(...)
        MovesTransform.new.apply(new.parse(...))
      end

      private

      class MovesTransform < Parslet::Transform
        rule(dir: simple(:dir)) { dir.to_sym }
        rule(moves: sequence(:moves)) { moves }
      end
    end
  end
end
