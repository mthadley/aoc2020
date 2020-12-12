module AdventOfCode
  class Day12 < Day
    input_file do |lines|
      lines.map { Instruction.parse(_1) }
    end

    part1 answer: 2057 do
      ship = Ship.new

      input.each { ship.follow(_1) }

      ship.manhattan_from_origin
    end

    class Ship
      attr_reader :position

      def initialize
        @position = Point.origin
        @direction = 0
      end

      def follow(instruction)
        case instruction.ins
        when :N
          move(Point.north, instruction.val)
        when :S
          move(Point.south, instruction.val)
        when :E
          move(Point.east, instruction.val)
        when :W
          move(Point.west, instruction.val)
        when :L
          turn(-instruction.val)
        when :R
          turn(instruction.val)
        when :F
          move(direction_to_point, instruction.val)
        end
      end

      def manhattan_from_origin
        @position.x.abs + @position.y.abs
      end

      private

      def move(point, value)
        @position += point * value
      end

      def turn(angle)
        @direction = (@direction + angle) % 360
      end

      def direction_to_point
        case @direction
        when 0 then Point.east
        when 90 then Point.south
        when 180 then Point.west
        when 270 then Point.north
        end
      end
    end

    Instruction = Struct.new(:ins, :val, keyword_init: true) do
      FORMAT = /^(?<ins>[NSEWLRF])(?<val>\d+)$/

      def self.parse(string)
        if match = FORMAT.match(string)
          new(ins: match[:ins].to_sym, val: match[:val].to_i)
        end
      end
    end
  end
end
