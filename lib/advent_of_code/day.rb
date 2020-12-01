class Day
  def self.input_file(name, &block)
    @@input_filename = name
    @@parser = block
  end

  def part_one
    "N/A"
  end

  def part_two
    "N/A"
  end

  protected

  def input
    @input ||=
      begin
        file_path = File.expand_path("../../input/#{@@input_filename}", __dir__)
        content = File.readlines(file_path)

        if @@parser.nil?
          content
        else
          @@parser.call(content)
        end
      end
  end
end
