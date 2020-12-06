require "set"

module AdventOfCode
  class Day6 < Day
    input_file split_lines: false do |content|
      content.split("\n\n").map { |group| Group.parse(group) }
    end

    part1 answer: 6382 do
      input.sum(&:total_questions_answered_yes)
    end

    part2 answer: 3197 do
      input.sum(&:total_quetions_all_answered_yes)
    end

    class Group
      def self.parse(group)
        answers_per_person = group.lines(chomp: true).map do |line|
          Set.new(line.chars)
        end

        new(answers_per_person)
      end

      def initialize(answers)
        @answers = answers
      end

      def total_questions_answered_yes
        @answers.reduce(:|).size
      end

      def total_quetions_all_answered_yes
        @answers.reduce(:&).size
      end
    end
  end
end
