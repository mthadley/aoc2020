module AdventOfCode
  class Day12 < Day
    input_file do |lines|
      lines.map { Instruction.parse(_1) }
    end

    part1 answer: 2057 do
      manhattan_for_ship(DirectionalShip)
    end

    part2 answer: 71504 do
      manhattan_for_ship(WaypointShip)
    end

    private

    def manhattan_for_ship(ship_class)
      ship = ship_class.new
      input.each { ship.follow(_1) }
      ship.manhattan_from_origin
    end

    class Ship
      attr_accessor :position

      def initialize
        @position = Point.origin
      end

      def manhattan_from_origin
        @position.x.abs + @position.y.abs
      end

      def follow(instruction)
        fail NotImplementedError
      end
    end

    class DirectionalShip < Ship
      def initialize
        super
        @direction = 0
      end

      def follow(instruction)
        case instruction.ins
        when :N then move(Point.north, instruction.val)
        when :S then move(Point.south, instruction.val)
        when :E then move(Point.east, instruction.val)
        when :W then move(Point.west, instruction.val)
        when :L then turn(-instruction.val)
        when :R then turn(instruction.val)
        when :F then move(direction_to_point, instruction.val)
        end
      end

      private

      def move(point, magnitude)
        self.position += point * magnitude
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

    class WaypointShip < Ship
      def initialize
        super
        @waypoint = Point.new(10, 1)
      end

      def follow(instruction)
        case instruction.ins
        when :N then move_waypoint(Point.north, instruction.val)
        when :S then move_waypoint(Point.south, instruction.val)
        when :E then move_waypoint(Point.east, instruction.val)
        when :W then move_waypoint(Point.west, instruction.val)
        when :L then rotate_waypoint(instruction.val)
        when :R then rotate_waypoint(-instruction.val)
        when :F then move_ship(instruction.val)
        end
      end

      private

      def move_waypoint(point, magnitude)
        @waypoint += point * magnitude
      end

      def rotate_waypoint(degrees)
        radians = degrees * Math::PI / 180

        @waypoint = Point.new(
          @waypoint.x * Math.cos(radians).to_i - @waypoint.y * Math.sin(radians).to_i,
          @waypoint.x * Math.sin(radians).to_i + @waypoint.y * Math.cos(radians).to_i
        )
      end

      def move_ship(times)
        self.position += @waypoint * times
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
