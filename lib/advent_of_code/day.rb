class AdventOfCode
  class Day
    def self.input_file(
      name = "#{self.name.split("::").last.downcase}.txt",
      split_lines: true,
      &block
    )
      @@input_filename = name
      @@input_parser = block
      @@input_split_lines = split_lines
    end

    class << self
      alias_method :has_input_file, :input_file
    end

    def part1
    end

    def part2
    end

    protected

    def input
      @input ||=
        begin
          file_path = File.expand_path("../../input/#{@@input_filename}", __dir__)

          content =
            if @@input_split_lines
              File.readlines(file_path, chomp: true)
            else
              File.read(file_path)
            end

          if @@input_parser.nil?
            content
          else
            @@input_parser.call(content)
          end
        end
    end
  end
end
