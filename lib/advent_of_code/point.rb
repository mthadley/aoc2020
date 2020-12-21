module AdventOfCode
  class Point
    attr_reader :x, :y

    def self.origin
      new(0, 0)
    end

    def self.cardinals
      cardinals = [-1, 0, 1].repeated_permutation(2).map { new(_1, _2) }
      cardinals.delete(origin)
      cardinals
    end

    def self.north
      new(0, 1)
    end

    def self.south
      new(0, -1)
    end

    def self.east
      new(1, 0)
    end

    def self.west
      new(-1, 0)
    end

    def initialize(x, y)
      @x = x
      @y = y
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      x == other.x && y == other.y
    end
    alias_method :eql?, :==

    def hash
      [x, y].hash
    end

    def +(other)
      self.class.new(x + other.x, y + other.y)
    end

    def %(mod)
      self.class.new(x % mod, y % mod)
    end

    def /(mod)
      self.class.new(x / mod, y / mod)
    end

    def *(number)
      fail ArgumentError, "#{number.class} is not a number" unless number.is_a?(Numeric)

      self.class.new(x * number, y * number)
    end

    def inspect
      "(#{x}, #{y})"
    end
  end
end
