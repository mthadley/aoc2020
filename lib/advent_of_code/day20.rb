require "set"

module AdventOfCode
  class Day20 < Day
    input_file split_lines: false do |content|
      content.split("\n\n").map { |chunk| Tile.parse(chunk) }
    end
    alias_method :tiles, :input

    part1 answer: 64802175715999 do
      TileSet.new(tiles).corners.map(&:id).inject(:*)
    end

    part2 answer: 2146 do
      tile_set = TileSet.new(tiles).remove_borders!

      5.times do |i|
        break if tile_set.count_monster_waves.nonzero?
        tile_set.rotate!
      end

      tile_set.count_monster_waves
    end

    class TileSet
      MONSTER = <<-MONSTER.gsub(/z/, " ").lines(chomp: true).map(&:chars).freeze
                  #z
#    ##    ##    ###
 #  #  #  #  #  #  z
      MONSTER

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
        @image ||=
          begin
            align_tiles
            @image
          end
      end

      def rotate!
        @image = image.map { |row| row.map(&:rotate) }.transpose.reverse
        self
      end

      def flip!
        @image = image.map { |row| row.map(&:flip).reverse }
        self
      end

      def remove_borders!
        image.flatten.each(&:remove_borders!)
        self
      end

      def count_monster_waves
        monster_points = Set.new
        each_char_pos do |point|
          monster_points.merge(monster_points_at(point))
        end

        return 0 if monster_points.empty?

        count = 0
        each_char_pos do |point, char|
          if char == "#" && !monster_points.member?(point)
            count += 1
          end
        end
        count
      end

      def monster_points_at(char_point)
        points = Set.new
        each_monster_pos do |point, monster_char|
          return Set.new unless image_char = char_at(char_point + point)

          if monster_char == "#"
            return Set.new if image_char != monster_char
            points.add(char_point + point) if image_char == "#"
          end
        end
        points
      end

      def to_s
        s = ""
        each_char_pos do |point, char|
          s << "\n" if point.x.zero? && point.y >= 1
          s << char
        end
        s
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

        each_tile_pos do |point|
          next unless tile_at(point).nil?

          if last = tile_at(point + Point.west)
            match = nil
            match_for(last.right_edge_id, last).
              rotations.
              each do |tile|
                if tile.left_edge_id == last.right_edge_id
                  match = tile
                  break
                end
              end

            @image[point.y][point.x] = match
          else
            last = tile_at(point + Point.south)

            match = nil
            match_for(last.bottom_edge_id, last).
              rotations.
              find do |tile|
                if tile.top_edge_id == last.bottom_edge_id
                  match = tile
                  break
                end
              end

            @image[point.y][point.x] = match
          end
        end
      end

      def image_dimen
        Math.sqrt(tiles.size).to_i
      end

      def tile_dimen
        image[0][0].dimen
      end

      def tile_at(point)
        image[point.y]&.at(point.x)
      end

      def char_at(point)
        tile_at(point / tile_dimen)&.at(point % tile_dimen)
      end

      def each_tile_pos
        (0..image_dimen - 1).each do |y|
          (0..image_dimen - 1).each do |x|
            yield Point.new(x, y)
          end
        end
      end

      def each_char_pos
        total_dimen = image_dimen * tile_dimen

        (0..total_dimen - 1).each do |y|
          (0..total_dimen - 1).each do |x|
            point = Point.new(x, y)

            yield point, char_at(point)
          end
        end
      end

      def each_monster_pos
        monster_x = MONSTER.first.size
        monster_y = MONSTER.size

        (0..monster_y - 1).each do |y|
          (0..monster_x - 1).each do |x|
            yield Point.new(x, y), MONSTER[y][x]
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

      def remove_borders!
        @data = data.map { |row| row[1..-2] }[1..-2]
        self
      end

      def rotate
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

          current = current.rotate
        end
      end

      def edge_ids
        rotations.map(&:left_edge_id)
      end

      def dimen
        @data.size
      end
    end
  end
end
