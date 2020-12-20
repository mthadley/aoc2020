module AdventOfCode
  class Day20 < Day
    input_file split_lines: false do |content|
      content.split("\n\n").map { |chunk| Tile.parse(chunk) }
    end
    alias_method :tiles, :input

    part1 answer: 64802175715999 do
      TileSet.new(tiles).corners.map(&:id).inject(:*)
    end

    class TileSet
      def initialize(tiles)
        @tiles_by_id = tiles.to_h { |t| [t.id, t] }
        @tiles_by_edge_id = tiles.each_with_object({}) do |tile, hash|
          tile.edge_ids.each do |edge_id|
            hash[edge_id] ||= []
            hash[edge_id] << tile.id
          end
        end
      end

      def tiles
        @tiles_by_id.values
      end

      def corners
        tiles.select { |tile| corner?(tile) }
      end

      private

      def corner?(tile)
        tile.edge_ids.count do |edge_id|
          @tiles_by_edge_id.fetch(edge_id).size == 2
        end == 4
      end
    end


    class Tile
      attr_reader :id, :data

      def self.parse(str)
        lines = str.lines(chomp: true)

        header_match = /^Tile (?<id>\d+):$/.match(lines.first)
        data = lines.drop(1).map { |line| line.chars }

        new(id: header_match[:id].to_i, data: data)
      end

      def initialize(id:, data:)
        @id, @data = id, data
      end

      def rotate_right
        self.class.new(id: id, data: data.transpose.reverse)
      end

      def flip
        self.class.new(id: id, data: data.map(&:reverse))
      end

      def left_edge_id
        @data.map(&:first).hash
      end

      def top_edge_id
      end

      def edge_ids
        current = self

        4.times.each_with_object([]) do |_i, ids|
          ids << current.left_edge_id
          ids << current.flip.left_edge_id

          current = current.rotate_right
        end
      end
    end
  end
end
