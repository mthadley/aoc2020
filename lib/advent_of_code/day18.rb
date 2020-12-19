require "parslet"

module AdventOfCode
  class Day18 < Day
    has_input_file

    part1 answer: 12918250417632 do
      input.sum { |line| evaluate(line, parser: MathParser.new) }
    end

    part2 answer: 171259538712010 do
      input.sum { |line| evaluate(line, parser: MathParser.new(precedence: {add: 2})) }
    end

    private

    def evaluate(str, parser:)
      MathTransformer.new.apply(parser.parse(str))
    end

    class MathParser < Parslet::Parser
      rule(:space) { match("\s").repeat(1) }
      rule(:integer) { match("[0-9]").repeat(1).as(:integer) }
      rule(:operator) { match("[+*]") }
      rule(:operation) {
        infix_expression(
          integer | parens,
          [space >> str('*').as(:op) >> space, precedence_for(:multiply), :left],
          [space >> str('+').as(:op) >> space, precedence_for(:add), :left ]
        )
      }
      rule(:parens) { str("(") >> expr >> str(")") }
      rule(:expr) { operation | parens | integer }

      root(:expr)

      def initialize(precedence: {})
        @precedence = {add: 1, multiply: 1}.merge(precedence)
      end

      private

      def precedence_for(op)
        @precedence.fetch(op) || 1
      end
    end

    class MathTransformer < Parslet::Transform
      rule(integer: simple(:n)) { n.to_i }
      rule(l: simple(:left), o: {op: simple(:op)}, r: simple(:right)) {
        left.public_send(op.to_sym, right)
      }
    end
  end
end
