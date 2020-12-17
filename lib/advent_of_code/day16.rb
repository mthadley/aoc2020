module AdventOfCode
  class Day16 < Day
    input_file(split_lines: false) { Notes.parse(_1) }

    alias_method :notes, :input

    part1 answer: 26053 do
      notes.rules.error_rate(notes.tickets)
    end

    part2 answer: 1515506256421 do
      valid_tickets = notes.tickets.filter { |ticket| notes.rules.valid?(ticket) }

      rules_for_col = valid_tickets.map(&:values).transpose.map do |col|
        notes.rules.
          rules.
          select do |rule|
            col.all? { |value| rule.valid?(value) }
          end.
          map(&:field_name)
      end

      mapping = {}

      while rules_for_col.any? { |col| col.any? }
        index = rules_for_col.find_index { |col| col.size == 1 }
        name = rules_for_col[index].first

        rules_for_col.each { |col| col.delete(name) }

        mapping[name] = index
      end

      mapping.map do |field_name, index|
        if field_name.start_with?("departure")
          notes.your_ticket.values[index]
        else
          1
        end
      end.reduce(:*)
    end

    Notes = Struct.new(:rules, :tickets, :your_ticket, keyword_init: true) do
      def self.parse(str)
        rules_section, your_ticket_section, tickets_section = str.split("\n\n")

        new(
          rules: Rules.new(
            rules_section.lines(chomp: true).map { Rule.parse!(_1) }
          ),
          your_ticket: Ticket.parse(
            your_ticket_section.lines(chomp: true).drop(1).first
          ),
          tickets: tickets_section.lines(chomp: true).drop(1).map { Ticket.parse(_1) }
        )
      end
    end

    class Rules
      attr_reader :rules

      def initialize(rules)
        @rules = rules
      end

      def error_rate(tickets)
        tickets.sum do |ticket|
          ticket.values.find { !valid_value?(_1) } || 0
        end
      end

      def valid?(ticket)
        ticket.values.all? { valid_value?(_1) }
      end

      private

      def valid_value?(value)
        rules.any? { |rule| rule.valid?(value) }
      end
    end

    class Rule
      FORMAT = /^
        (?<field_name>.+):
        \s+
        (?<range_start_a>\d+)-(?<range_end_a>\d+)
        \s+or\s+
        (?<range_start_b>\d+)-(?<range_end_b>\d+)
      $/x

      attr_reader :field_name

      def self.parse!(str)
        match = FORMAT.match(str) or fail ArgumentError, "Not a rule: \"#{str}\""

        new(
          field_name: match[:field_name],
          valid_ranges: [
            Range.new(match[:range_start_a].to_i, match[:range_end_a].to_i),
            Range.new(match[:range_start_b].to_i, match[:range_end_b].to_i),
          ]
        )
      end

      def initialize(field_name:, valid_ranges:)
        @field_name = field_name
        @valid_ranges = valid_ranges
      end

      def valid?(value)
        @valid_ranges.any? { |range| range.cover?(value) }
      end
    end

    class Ticket
      attr_reader :values

      def self.parse(str)
        new(str.split(",").map(&:to_i))
      end

      def initialize(values)
        @values = values
      end
    end
  end
end
