module AdventOfCode
  class Day4 < Day
    has_input_file split_lines: false

    part1 answer: 228 do
      passport_file.passports.count(&:has_all_fields?)
    end

    part2 answer: 175 do
      passport_file.passports.count(&:valid?)
    end

    private

    def passport_file
      @passport_file ||= PassportFile.parse!(input)
    end

    class PassportFile
      attr_reader :passports

      def self.parse!(string)
        passports = string.split("\n\n").map { |fields| Passport.parse!(fields) }
        new(passports)
      end

      def initialize(passports)
        @passports = passports
      end
    end

    class Passport
      REQUIRED_FIELDS = %i[byr iyr eyr hgt hcl ecl pid]

      FIELD_FORMAT = /(?<name>\w+):(?<value>.+?)(\s|$)/m

      COLOR_FORMAT = /#[0-9a-f]{6}/
      PID_FORMAT = /^\d{9}$/
      HGT_FORMAT = /(?<measurement>\d+)(?<unit>cm|in)/

      EYE_COLORS = %w[amb blu brn gry grn hzl oth]

      def self.parse!(string)
        matches = []
        string.scan(FIELD_FORMAT) { matches << Regexp.last_match }

        fail ArgumentError, "Not a valid passport: \"#{string}\"" unless matches.any?

        fields = matches.map { |match| [match[:name].to_sym, match[:value]] }.to_h
        new(fields)
      end

      def initialize(fields)
        @fields = fields
      end

      def has_all_fields?
        REQUIRED_FIELDS.all? { |field| @fields.has_key?(field) }
      end

      def valid?
        REQUIRED_FIELDS.all? do |field|
          value = @fields[field]
          return false unless value

          valid_field?(field, value)
        end
      end

      private

      def valid_field?(name, value)
        case name
        when :byr then value.to_i.between?(1920, 2002)
        when :iyr then value.to_i.between?(2010, 2020)
        when :eyr then value.to_i.between?(2020, 2030)
        when :hgt
          if match = HGT_FORMAT.match(value)
            measurement = match[:measurement].to_i

            case match[:unit]
            when "cm" then measurement.between?(150, 193)
            when "in" then measurement.between?(59, 76)
            end
          end
        when :hcl then COLOR_FORMAT.match?(value)
        when :ecl then EYE_COLORS.include?(value)
        when :pid then PID_FORMAT.match?(value)
        when :cid then true
        end
      end
    end
  end
end
