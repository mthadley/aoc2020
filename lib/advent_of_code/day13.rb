module AdventOfCode
  class Day13 < Day
    has_input_file

    part1 answer: 296 do
      fastest_bus = bus_ids.filter { _1.is_a?(Integer) }.min_by { wait_time(_1) }
      fastest_bus * wait_time(fastest_bus)
    end

    part2 answer: 535296695251210 do
      res = 0
      step = 1

      bus_ids.each.with_index do |bus_id, i|
        next unless bus_id.is_a?(Integer)

        res = (res..).step(step) do |n|
          break n if (n + i) % bus_id == 0
        end

        step *= bus_id
      end

      res
    end

    private

    def departs_at?(bus_id, timestamp)
      (timestamp % bus_id).zero?
    end

    def wait_time(bus_id)
      time = 0
      time += bus_id until time >= earliest_timestamp
      time - earliest_timestamp
    end

    def earliest_timestamp
      @earliest_timestamp ||= input.first.to_i
    end

    def bus_ids
      @bus_ids ||= input[1].split(",").map { |s| s == "x" ? s : s.to_i }
    end
  end
end
