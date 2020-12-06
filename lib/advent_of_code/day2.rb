module AdventOfCode
  class Day2 < Day
    input_file do |lines|
      lines.map { Password.parse(_1) }
    end

    part1 answer: 625 do
      input.count(&:valid_for_range_policy?)
    end

    part2 answer: 391 do
      input.count(&:valid_for_index_policy?)
    end

    private

    Password = Struct.new(:content, :special_char, :first_num, :second_num, keyword_init: true) do
      FORMAT = /^
        (?<first>\d+)
        -
        (?<second>\d+)
        \s+
        (?<special_char>\w):
        \s+
        (?<content>\w*)
      $/x

      def self.parse(string)
        match = FORMAT.match(string)

        fail ArgumentError, "Not a valid password: \"#{string}\"" unless match

        new(
          content: match[:content],
          special_char: match[:special_char],
          first_num: match[:first].to_i,
          second_num: match[:second].to_i
        )
      end

      def valid_for_range_policy?
        (first_num..second_num).cover?(content.chars.count(special_char))
      end

      def valid_for_index_policy?
        first_char = content[first_num - 1] == special_char
        second_char = content[second_num - 1] == special_char

        first_char ^ second_char
      end
    end
  end
end
