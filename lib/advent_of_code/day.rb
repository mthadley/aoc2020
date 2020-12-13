module AdventOfCode
  class Day
    def self.slow!
      define_method(:slow?) { true }
    end

    def self.input_file(
      name = "#{self.name.split("::").last.downcase}.txt",
      split_lines: true,
      &block
    )
      define_method(:input_filename) { name }
      define_method(:input_parser) { block }
      define_method(:input_split_lines?) { split_lines }
    end

    def self.part1(**args, &block)
      add_part(:part1, **args, &block)
    end

    def self.part2(**args, &block)
      add_part(:part2, **args, &block)
    end

    def self.add_part(part, answer: nil, &block)
      define_method(part) do
        result = instance_eval(&block)

        Result.new(result, answer)
      end
    end

    class << self
      alias_method :has_input_file, :input_file
    end

    part1 {}
    part2 {}

    class Result
      attr_reader :answer

      def initialize(answer, expected)
        @answer = answer
        @expected = expected
      end

      def correct?
        @expected && answer == @expected
      end
    end

    def slow?
      false
    end

    protected

    def input
      @input ||=
        begin
          file_path = File.expand_path("../../input/#{input_filename}", __dir__)

          content =
            if input_split_lines?
              File.readlines(file_path, chomp: true)
            else
              File.read(file_path)
            end

          if input_parser.nil?
            content
          else
            input_parser.call(content)
          end
        end
    end
  end
end
