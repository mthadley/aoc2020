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
        @edges = {}

        rules.each do |rule|
          @edges[rule.key] = rule.deps
        end
      end

      def colors_needed_for(bag)
        colors = Set.new
        seen = Set.new

        @edges.keys.each do |start_bag|
          next if start_bag == bag

          if seen.member?(start_bag)
            colors.add(start_bag)
          elsif path = path_to(bag, current: start_bag)
            seen |= path
            colors.add(start_bag)
          end
        end

        colors.size
      end

      def path_to(needle, current:, seen: Set.new)
        return seen if needle == current

        @edges[current].each do |edge|
          next if seen.member?(edge.bag)

          if path = path_to(needle, current: edge.bag, seen: Set[edge.bag] | seen)
            return path
          end
        end

        nil
      end

      def total_bags_for(bag)
        @edges[bag].sum do |edge|
          edge.count * (total_bags_for(edge.bag) + 1)
        end
      end
    end


    Rule = Struct.new(:key, :deps, keyword_init: true)
    Bag = Struct.new(:condition, :color, keyword_init: true)
    BagCount = Struct.new(:bag, :count, keyword_init: true)

    class RuleParser
      def self.parse!(line)
        new(StringScanner.new(line)).parse!
      end

      def initialize(scanner)
        @s = scanner
      end

      def parse!
        key_bag = BagParser.new(@s).parse!

        fail ArgumentError, "Expected a bag at #{@s.pos}" unless key_bag

        deps =
          if @s.match?(/ contain no other bags./)
            []
          else
            parse_deps!
          end

        Rule.new(key: key_bag, deps: deps)
      end

      def parse_deps!
        @s.skip(/\s+contain\s+/)

        deps = []
        deps << parse_dep! until @s.eos?
        deps
      end

      def parse_dep!
        @s.scan(/(?<count>\d+)\s+/) or fail ArgumentError, "Expected count: \"#{@s.rest}\""
        count = @s[:count]

        bag = BagParser.new(@s).parse!

        @s.scan(/,\s+|\./) or fail ArgumentError, "Expected period or comma: \"#{@s.rest}\""

        BagCount.new(bag: bag, count: count.to_i)
      end
    end

    class BagParser
      BAG_FORMAT = /(?<condition>\w+)\s+(?<color>\w+)\s+bags?/

      def initialize(string_scanner)
        @s = string_scanner
      end

      def parse!
        @s.scan BAG_FORMAT or fail ArgumentError, "Invalid bag: #{@s.rest}"

        Bag.new(condition: @s[:condition], color: @s[:color])
      end
    end
  end
end
