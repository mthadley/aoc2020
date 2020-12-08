require "set"

module AdventOfCode
  class Day8 < Day
    has_input_file

    part1 answer: 1475 do
      console = GameConsole.parse_instructions!(input)
      console.run
    rescue GameConsole::LoopError
      console.acc
    end

    part2 answer: 1270 do
      acc_after_fix(GameConsole.parse_instructions!(input))
    end

    private

    def acc_after_fix(console)
      mod_idx = 0

      begin
        console.reset!

        mod_idx += console.instructions.drop(mod_idx).find_index { fixable?(_1) }

        flip_instruction!(console, mod_idx)

        console.run
      rescue GameConsole::LoopError
        mod_idx += 1
        retry
      end

      console.acc
    end

    def fixable?(ins)
      [:jmp, :nop].include?(ins.code)
    end

    def flip_instruction!(console, mod_idx)
      ins = console.instructions[mod_idx]
      new_code =
        case ins.code
        when :nop then :jmp
        when :jmp then :nop
        end

      new_instructions = console.instructions.clone
      new_instructions[mod_idx] = Instruction.new(code: new_code, arg: ins.arg)

      console.instructions = new_instructions
    end

    class GameConsole
      class LoopError < StandardError; end

      attr_accessor :instructions
      attr_reader :acc, :ic

      def self.parse_instructions!(lines)
        new(lines.map { Instruction.parse!(_1) })
      end

      def initialize(instructions)
        @original_instructions = instructions
        reset!
      end

      def reset!
        @instructions = @original_instructions
        @acc = 0
        @ic = 0
      end

      def run
        lines_ran = Set.new

        while ic < instructions.size
          fail LoopError if lines_ran.member?(ic)

          lines_ran.add(ic)
          execute(instructions[ic])
        end
      end

      private

      def execute(ins)
        case ins.code
        when :acc
          @acc += ins.arg
          @ic += 1
        when :jmp
          @ic += ins.arg
        when :nop
          @ic += 1
        else
          fail "Unknown instruction: #{ins.code}"
        end
      end
    end

    Instruction = Struct.new(:code, :arg, keyword_init: true) do
      INSTRUCTION_FORMAT = /^(?<instruction>\w+)\s+(?<arg>[+-]\d+)$/

      def self.parse!(string)
        if match = INSTRUCTION_FORMAT.match(string)
          new(code: match[:instruction].to_sym, arg: match[:arg].to_i)
        else
          fail ArgumentError, "Not a valid instruction: \"#{string}\""
        end
      end
    end
  end
end
