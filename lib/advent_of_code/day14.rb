module AdventOfCode
  class Day14 < Day
    has_input_file

    part1 answer: 4886706177792 do
      get_mem_values(Instruction)
    end

    part2 answer: 3348493585827 do
      get_mem_values(InstructionV2)
    end

    private

    def get_mem_values(ins_class)
      program = Program.new
      input.each { |line| ins_class.parse!(line).run(program) }
      program.mem.values.sum
    end

    class Program
      attr_accessor :mem, :mask

      def initialize
        @mem = {}
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
        const_get(:SetMask).parse(string) ||
          const_get(:SetMem).parse(string) or
          fail ArgumentError, "Not a valid instruction: \"#{string}\""
      end

      class SetMask
        FORMAT = /^mask = (?<mask>\w+)$/
        attr_reader :mask

        def self.parse(string)
          if match = FORMAT.match(string)
            new(match[:mask])
          end
        end

        def initialize(mask)
          @mask = mask
        end

        def run(program)
          program.mask = Mask.new(mask)
        end
      end

      class SetMem
        FORMAT = /^mem\[(?<loc>\d+)\] = (?<val>\d+)$/
        attr_reader :loc, :val

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
          program.mem[loc] = program.mask.apply(val)
        end
      end
    end

    class Decoder
      def initialize(mask_s)
        @mask = mask_s
      end

      def apply(loc)
        loc_chars = loc.to_s(2).rjust(@mask.size, "0").chars
        loc_tmpl =
          @mask.chars.zip(loc_chars).map do |mask_c, loc_c|
            case mask_c
            when "X" then "X"
            when "1" then "1"
            when "0" then loc_c
            end
          end.join

        [0, 1].repeated_permutation(loc_tmpl.count("X")).map do |perm|
          i = 0
          loc_tmpl.gsub(/X/) do
            num = perm[i]
            i += 1
            num
          end
        end
      end
    end

    class InstructionV2 < Instruction
      class SetMask < Instruction::SetMask
        def run(program)
          program.mask = Decoder.new(mask)
        end
      end

      class SetMem < Instruction::SetMem
        def run(program)
          program.mask.apply(loc).each do |address|
            program.mem[address] = val
          end
        end
      end
    end
  end
end
