class AdventOfCode
  class Day
    def self.input_file(name = "#{self.name.split("::").last.downcase}.txt", &block)
      @@input_filename = name
      @@input_parser = block
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
          content = File.readlines(file_path)

          if @@input_parser.nil?
            content
          else
            @@input_parser.call(content)
          end
        end
    end
  end
end
