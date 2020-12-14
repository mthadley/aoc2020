module AdventOfCode
  class Day14 < Day
    input_file do |lines|
      lines.map { Instruction.parse!(_1) }
    end

    part1 answer: 4886706177792 do
      program = Program.new

      input.each { |instruction| instruction.run(program) }

      program.mem.values.sum
    end

    class Program
      attr_accessor :mem, :mask

      def initialize
        @mem = {}
        @mask = Mask.new("0")
      end
    end

    class Mask
      def initialize(binary_string)
        ones_mask = []
        zeros_mask = []

        binary_string.chars.each do |char|
          case char
          when "X"
            ones_mask << 0
            zeros_mask << 1
          else
            ones_mask << char
            zeros_mask << char
          end
        end

        @ones_mask = ones_mask.join.to_i(2)
        @zeros_mask = zeros_mask.join.to_i(2)
      end

      def apply(num)
        (num | @ones_mask) & @zeros_mask
      end
    end

    class Instruction
      def self.parse!(string)
        SetMask.parse(string) ||
          SetMem.parse(string) or
          fail ArgumentError, "Not a valid instruction: \"#{string}\""
      end

      class SetMask
        FORMAT = /^mask = (?<mask>\w+)$/

        def self.parse(string)
          if match = FORMAT.match(string)
            new(match[:mask])
          end
        end

        def initialize(mask)
          @mask = mask
        end

        def run(program)
          program.mask = Mask.new(@mask)
        end
      end

      class SetMem
        FORMAT = /^mem\[(?<loc>\d+)\] = (?<val>\d+)$/

        def self.parse(string)
          if match = FORMAT.match(string)
            new(loc: match[:loc].to_i, val: match[:val].to_i)
          end
        end

        def initialize(loc:, val:)
          @loc = loc
          @val = val
        end

        def run(program)
          program.mem[@loc] = program.mask.apply(@val)
        end
      end
    end
  end
end
