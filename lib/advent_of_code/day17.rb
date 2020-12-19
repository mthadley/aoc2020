require "set"

module AdventOfCode
  class Day17 < Day
    slow!

    has_input_file

    part1 answer: 295 do
      space = init_space(Space3D.new) { |x, y| Point3D.new(x, y, 0) }
      6.times { space = space.succ }
      space.active_count
    end

    part2 answer: 1972 do
      space = init_space(Space4D.new) { |x, y| Point4D.new(x, y, 0, 0) }
      6.times { space = space.succ }
      space.active_count
    end

    private

    def init_space(space)
      input.each.with_index do |line, y|
        line.chars.each.with_index do |cell, x|
          space.activate(yield x, y) if cell == "#"
        end
      end

      space
    end

    class Space3D
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
        point_class.ordinals.count { |ord| active?(point + ord) }
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

      protected

      def point_class
        Point3D
      end

      def each_contained_point
        range_for(:x).each do |x|
          range_for(:y).each do |y|
            range_for(:z).each do |z|
              yield point_class.new(x, y, z)
            end
          end
        end
      end

      def range_for(axis)
        start, last = @space.map(&axis).minmax
        Range.new(start - 1, last + 1)
      end
    end

    class Space4D < Space3D

      protected

      def point_class
        Point4D
      end

      def each_contained_point
        range_for(:x).each do |x|
          range_for(:y).each do |y|
            range_for(:z).each do |z|
              range_for(:z).each do |w|
                yield point_class.new(x, y, z, w)
              end
            end
          end
        end
      end
    end

    class Point3D
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

      def hash
        [x, y, z].hash
      end
    end

    class Point4D
      attr_reader :x, :y, :z, :w

      def self.origin
        new(0, 0, 0, 0)
      end

      def self.ordinals
        ordinals = [-1, 0, 1].repeated_permutation(4).map { new(_1, _2, _3, _4) }
        ordinals.delete(origin)
        ordinals
      end

      def initialize(x, y, z, w)
        @x, @y, @z, @w = x, y, z, w
      end

      def +(other)
        self.class.new(x + other.x, y + other.y, z + other.z, w + other.w)
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        x == other.x && y == other.y && z == other.z && w == other.w
      end

      alias_method :eql?, :==

      def hash
        [x, y, z, w].hash
      end
    end
  end
end
