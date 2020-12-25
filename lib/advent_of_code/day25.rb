module AdventOfCode
  class Day25 < Day
    KEY_A = 3469259
    KEY_B = 13170438
    SUBJECT_NUM = 7
    MAGIC_NUM = 20201227

    part1 answer: 7269858 do
      key = 1

      loop_size_for(KEY_A).times do
        key *= KEY_B
        key = key % MAGIC_NUM
      end

      key
    end

    private

    def loop_size_for(key)
      val = 1
      loops = 0

      until val == key
        val *= SUBJECT_NUM
        val = val % MAGIC_NUM
        loops += 1
      end

      loops
    end
  end
end
