module AdventOfCode
  class Day23 < Day
    INPUT = "853192647"

    part1 answer: "97624853" do
      cups = Node.from(INPUT.chars.map(&:to_i))
      cups = shuffle_cups(cups, iterations: 100)
      cups.find { |node| node.val == 1 }.drop(1).map(&:val).join
    end

    private

    def shuffle_cups(cups, iterations:)
      index = cups.each_with_object({}) do |node, hash|
        hash[node.val] = node
      end
      cups_max = cups.max.val

      current = cups
      iterations.times do
        selection = current.next.take(3)
        selection_values = selection.map(&:val)

        current.next = current.next.next.next.next

        target_val = (current.val - 1).downto(1).find { !selection_values.include?(_1) }
        target_val ||= (cups_max).downto(1).find { !selection_values.include?(_1) }

        target_node = index.fetch(target_val)
        target_node_next = target_node.next

        target_node.next = selection.first
        selection.last.next = target_node_next

        current = current.next
      end

      current
    end

    class Node
      include Enumerable
      include Comparable

      attr_accessor :val, :next

      def initialize(val, next: nil)
        @val = val
        @next = binding.local_variable_get(:next)
      end

      def <=>(other)
        val <=> other.val
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        val == other.val
      end

      def self.from(enumerable)
        current = nil
        head = nil

        enumerable.each do |val|
          if current.nil?
            current = new(val)
            head = current
          else
            current.next = new(val)
            current = current.next
          end
        end

        current.next = head
        head
      end

      def each
        start = self
        current = self

        loop do
          yield current
          current = current.next
          break if current == start
        end
      end

      def inspect
        "<Node @val=#{val}>"
      end
    end
  end
end
