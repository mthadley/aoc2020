require "parslet"

module AdventOfCode
  class Day24 < Day
    input_file do |lines|
      lines.map { |line| MovesParser.parse(line) }
    end
    alias_method :moves, :input

    part1 answer: 436 do
      points.each_with_object(Set.new) do |point, flipped|
        flipped.member?(point) ? flipped.delete(point) : flipped.add(point)
      end.size
    end

    private

    def points
      moves.map do |dirs|
        dirs.map { |dir| dir_to_point(dir) }.reduce(:+)
      end
    end

    def dir_to_point(dir)
      case dir
      when :e  then Point.new(2, 0)
      when :se then Point.new(1, -1)
      when :sw then Point.new(-1, -1)
      when :w  then Point.new(-2, 0)
      when :nw then Point.new(-1,  1)
      when :ne then Point.new(1, 1)
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
