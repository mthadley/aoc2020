require "parslet"

module AdventOfCode
  class Day19 < Day
    input_file split_lines: false do |content|
      rule_lines, message_lines = content.split("\n\n")

      {
        rules: rule_lines.lines(chomp: true),
        messages: message_lines.lines(chomp: true)
      }
    end

    part1 answer: 126 do
      regex = RuleSet.new(rules).to_regex
      input[:messages].count { |msg| regex.match?(msg) }
    end

    private

    def rules
      @rules ||=
        input[:rules].map { RuleTransform.new.apply(RuleParser.new.parse(_1)) }
    end

    class RuleSet
      def initialize(rules)
        @rules = rules.to_h { |rule| [rule.id, rule] }
      end

      def to_s
        go_s(0)
      end

      def to_regex
        Regexp.new("^#{to_s}$")
      end

      private

      def go_s(id)
        rule = @rules.fetch(id)

        case rule
        when LiteralRule
          rule.char
        when RefRule
          result = rule.sub_rules.map do |sub_rule|
            sub_rule.map do |sub_id|
              go_s(sub_id)
            end.join
          end.join("|")

          "(?:" + result + ")"
        end
      end
    end

    class RuleParser < Parslet::Parser
      rule(:ws) { match("\s").repeat(1) }
      rule(:int) { match("[0-9]").repeat(1) }
      rule(:id_ref) { (int.as(:id) >> ws.maybe).repeat(1).as(:ids) }
      rule(:ref_rule) { (str("| ").maybe >> id_ref).repeat(1).as(:sub_rules) }
      rule(:literal_rule) { str('"') >> match("[a-f]").as(:char) >> str('"') }
      rule(:message_rule) { int.as(:id) >> str(":") >> ws >> (ref_rule | literal_rule) }

      root :message_rule
    end

    class RuleTransform < Parslet::Transform
      rule(id: simple(:id)) { id.to_i }
      rule(ids: sequence(:ids)) { ids }
      rule(id: simple(:id), char: simple(:char)) { LiteralRule.new(id.to_i, char.to_s) }
      rule(id: simple(:id), sub_rules: subtree(:rules)) { RefRule.new(id.to_i, rules) }
    end

    RefRule = Struct.new(:id, :sub_rules)
    LiteralRule = Struct.new(:id, :char)
  end
end
