require "strscan"
require "set"

module AdventOfCode
  class Day7 < Day
    has_input_file

    part1 answer: 248 do
      rules.colors_needed_for(Bag.new(condition: "shiny", color: "gold"))
    end

    part2 answer: 57281 do
      rules.total_bags_for(Bag.new(condition: "shiny", color: "gold"))
    end

    private

    def rules
      @rules ||= RuleSet.new(input.map { RuleParser.parse!(_1) })
    end

    class RuleSet
      def initialize(rules)
        @rules = rules
      end

      def colors_needed_for(bag, seen: Set.new)
        edges = edges_to_parent[bag]

        return if edges.nil?

        edges.each do |edge|
          next if seen.member?(edge.bag)

          seen.add(edge.bag)
          colors_needed_for(edge.bag, seen: seen)
        end

        seen.size
      end

      def total_bags_for(bag)
        edges_to_children[bag].sum do |edge|
          edge.count * (total_bags_for(edge.bag) + 1)
        end
      end

      private

      def edges_to_parent
        @edges_to_parent ||= @rules.each_with_object({}) do |rule, edges|
          rule.deps.each do |edge|
            edges[edge.bag] ||= []
            edges[edge.bag] << BagCount.new(count: edge.count, bag: rule.key)
          end
        end
      end

      def edges_to_children
        @edges_to_children ||= @rules.each_with_object({}) do |rule, edges|
          edges[rule.key] = rule.deps
        end
      end
    end

    Rule = Struct.new(:key, :deps, keyword_init: true)
    Bag = Struct.new(:condition, :color, keyword_init: true)
    BagCount = Struct.new(:bag, :count, keyword_init: true)

    RuleParser = Struct.new(:s) do
      def self.parse!(line)
        new(StringScanner.new(line)).parse!
      end

      def parse!
        key_bag = BagParser.new(s).parse!

        fail ArgumentError, "Expected a bag at #{s.pos}" unless key_bag

        deps =
          if s.match?(/ contain no other bags./)
            []
          else
            parse_deps!
          end

        Rule.new(key: key_bag, deps: deps)
      end

      def parse_deps!
        s.skip(/\s+contain\s+/)

        deps = []
        deps << parse_dep! until s.eos?
        deps
      end

      private

      def parse_dep!
        s.scan(/(?<count>\d+)\s+/) or fail ArgumentError, "Expected count: \"#{s.rest}\""
        count = s[:count]

        bag = BagParser.new(s).parse!

        s.scan(/,\s+|\./) or fail ArgumentError, "Expected period or comma: \"#{s.rest}\""

        BagCount.new(bag: bag, count: count.to_i)
      end
    end

    BagParser = Struct.new(:s) do
      BAG_FORMAT = /(?<condition>\w+)\s+(?<color>\w+)\s+bags?/

      def parse!
        s.scan BAG_FORMAT or fail ArgumentError, "Invalid bag: #{s.rest}"

        Bag.new(condition: s[:condition], color: s[:color])
      end
    end
  end
end
