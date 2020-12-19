require "set"

module AdventOfCode
  class Day17 < Day
    has_input_file

    part1 answer: 295 do
      space = initial_space
      6.times { space = space.succ }
      space.active_count
    end

    private

    def initial_space
      space = Space.new

      input.each.with_index do |line, y|
        line.chars.each.with_index do |cell, x|
          space.activate(Point.new(x, y, 0)) if cell == "#"
        end
      end

      space
    end

    class Space
      def initialize(set = Set.new)
        @space = set
      end

      def activate(point)
        @space.add(point)
      end

      def active?(point)
        @space.member?(point)
      end

      def active_count
        @space.size
      end

      def active_count_around(point)
        Point.ordinals.count { |ord| active?(point + ord) }
      end

      def succ
        next_space = self.class.new

        each_contained_point do |point|
          active_around = active_count_around(point)

          should_activate =
            (active?(point) && (2..3).cover?(active_around)) ||
            (!active?(point) && active_around == 3)

          next_space.activate(point) if should_activate
        end

        next_space
      end

      private

      def each_contained_point
        range_for(:x).each do |x|
          range_for(:y).each do |y|
            range_for(:z).each do |z|
              yield Point.new(x, y, z)
            end
          end
        end
      end

      def range_for(axis)
        start, last = @space.map(&axis).minmax
        Range.new(start - 1, last + 1)
      end
    end

    class Point
      attr_reader :x, :y, :z

      def self.origin
        new(0, 0, 0)
      end

      def self.ordinals
        ordinals = [-1, 0, 1].repeated_permutation(3).map { new(_1, _2, _3) }
        ordinals.delete(origin)
        ordinals
      end

      def initialize(x, y, z)
        @x, @y, @z = x, y, z
      end

      def +(other)
        self.class.new(x + other.x, y + other.y, z + other.z)
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        x == other.x && y == other.y && z == other.z
      end

      alias_method :eql?, :==

      def inspect
        "(#{x}, #{y}, #{z})"
      end

      alias_method :to_s, :inspect

      def hash
        [x, y, z].hash
      end
    end
  end
end
