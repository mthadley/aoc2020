module AdventOfCode
  class Point
    attr_reader :x, :y

    def self.origin
      new(0, 0)
    end

    def self.cardinals
      [-1, 0, 1].
        repeated_permutation(2).
        map { Point.new(_1, _2) }.
        filter { origin != _1 }
    end

    def initialize(x, y)
      @x = x
      @y = y
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      x == other.x && y == other.y
    end

    def +(other)
      self.class.new(x + other.x, y + other.y)
    end
  end
end
