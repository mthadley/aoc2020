module AdventOfCode
  class Point
    attr_reader :x, :y

    def self.origin
      new(0, 0)
    end

    def initialize(x, y)
      @x = x
      @y = y
    end

    def +(other)
      self.class.new(x + other.x, y + other.y)
    end
  end
end
