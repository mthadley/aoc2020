require "parslet"

module AdventOfCode
  class Day18 < Day
    has_input_file

    part1 answer: 12918250417632 do
      input.sum { |line| evaluate(line) }
    end

    private

    def evaluate(str)
      MathTransformer.new.apply(MathParser.new.parse(str))
    end

    class MathParser < Parslet::Parser
      rule(:space) { match("\s").repeat(1) }
      rule(:integer) { match("[0-9]").repeat(1).as(:integer) }
      rule(:operator) { match("[+*]") }
      rule(:operation) {
        infix_expression(
          integer | parens,
          [space >> str('*').as(:op) >> space, 1, :left],
          [space >> str('+').as(:op) >> space, 1, :left]
        )
      }
      rule(:parens) { str("(") >> expr >> str(")") }
      rule(:expr) { operation | parens | integer }

      root(:expr)
    end

    class MathTransformer < Parslet::Transform
      rule(integer: simple(:n)) { n.to_i }
      rule(l: simple(:left), o: {op: simple(:op)}, r: simple(:right)) {
        left.public_send(op.to_sym, right)
      }
    end
  end
end
