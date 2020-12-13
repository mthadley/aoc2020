module AdventOfCode
  class Day13 < Day
    has_input_file

    part1 answer: 296 do
      fastest_bus = bus_ids.filter { _1 != "x" }.min_by { wait_time(_1) }
      fastest_bus * wait_time(fastest_bus)
    end

    private

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
