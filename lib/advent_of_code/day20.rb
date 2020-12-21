module AdventOfCode
  class Day20 < Day
    input_file split_lines: false do |content|
      content.split("\n\n").map { |chunk| Tile.parse(chunk) }
    end
    alias_method :tiles, :input

    part1 answer: 64802175715999 do
      TileSet.new(tiles).corners.map(&:id).inject(:*)
    end

    part2 do
      TileSet.new(tiles).print_image
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

        if @tiles_by_edge_id.values.any? { |tiles| tiles.size > 2 }
          fail ArgumentError, "Multiple matching sides!"
        end
      end

      def tiles
        @tiles_by_id.values
      end

      def corners
        tiles.select { |tile| corner?(tile) }
      end

      def image
        @image ||= begin
          align_tiles
          @image
        end
      end

      def rotate_right!
        image.map!(&:rotate_right)
      end

      def flip!
        image.map!(&:flip)
      end

      def print_image
        total_dimen = image_dimen * tile_dimen

        (0..total_dimen - 1).each do |y|
          (0..total_dimen - 1).each do |x|
            point = Point.new(x, y)
            print at(point % image_dimen).at(point % tile_dimen)
          end
          puts
        end
      end

      private

      def corner?(tile)
        tile.edge_ids.count { |edge_id| matching_sides?(edge_id) } == 4
      end

      def matching_sides?(edge_id)
        @tiles_by_edge_id.fetch(edge_id).size == 2
      end

      def match_for(edge_id, tile)
        tile_id = @tiles_by_edge_id.fetch(edge_id).find { |id| id != tile.id }
        @tiles_by_id.fetch(tile_id)
      end

      def align_tiles
        @image = Array.new(image_dimen) { Array.new(image_dimen) }

        corner_tile = corners.find do |tile|
          !matching_sides?(tile.left_edge_id) && !matching_sides?(tile.top_edge_id)
        end

        @image[0][0] = corner_tile

        each_cell do |point|
          next unless at(point).nil?

          if last = at(point + Point.west)
            match = nil
            match_for(last.right_edge_id, last).
              rotations.
              each do |tile|
               if tile.left_edge_id == last.right_edge_id
                 match = tile
                 break
               end
              end

            set(point, match)
          else
            last = at(point + Point.south)

            match =
              match_for(last.bottom_edge_id, last).
              rotations.
              find do |tile|
                tile.top_edge_id == last.bottom_edge_id
              end

            set(point, match)
          end
        end
      end

      def image_dimen
        Math.sqrt(tiles.size).to_i
      end

      def tile_dimen
        tiles.first.dimen
      end

      def at(point)
        image[point.y]&.at(point.x)
      end

      def set(point, tile)
        image[point.y][point.x] = tile
      end

      def each_cell
        (0..image_dimen - 1).each do |y|
          (0..image_dimen - 1).each do |x|
            yield Point.new(x, y)
          end
        end
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

      def right_edge_id
        @data.map(&:last).hash
      end

      def top_edge_id
        @data.first.hash
      end

      def bottom_edge_id
        @data.last.hash
      end

      def at(point)
        @data[point.y]&.at(point.x)
      end

      def rotations
        current = self

        4.times.each_with_object([]) do |_i, res|
          res << current
          res << current.flip

          current = current.rotate_right
        end
      end

      def edge_ids
        rotations.map(&:left_edge_id)
      end

      def dimen
        @data.first.size
      end
    end
  end
end
