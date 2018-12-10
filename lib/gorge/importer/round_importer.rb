require 'set'

module Gorge
  module Importer
    class RoundImporter < BaseImporter
      ROUND_IMPORT_BATCH_SIZE = 10_000

      def initialize(*args, **kwargs)
        super(*args, **kwargs)

        @l.module = 'rounds'
      end

      def import
        map_cache = generate_map_cache
        location_cache = generate_location_cache(map_cache)

        round_count = round_info.count

        total_batch_count = (round_count.to_f / ROUND_IMPORT_BATCH_SIZE).ceil
        @l.debug({ msg: 'Starting import.', round_count: round_count, batch_size: ROUND_IMPORT_BATCH_SIZE })

        new_rounds_in_source.each_with_index do |args, index|
          # TODO: This can't be the proper way
          new_round_hashes, skipped_rounds_count = *args

          new_round_data = new_round_hashes.map do |hsh|
            # startingLocation1 / startingLocation2 are *1-based* indices of
            # the names in this array.
            # In addition, if they are not defined, we want them to stay `nil`.
            # No special handling would be `nil.to_i - 1 == 0 - 1 == -1` which
            # would use the last location in the array.
            map_location_cache = location_cache.fetch(hsh.fetch(:mapName))

            locations_ary = JSON.parse(hsh.fetch(:locationNames))

            loc_1_idx = hsh.fetch(:startingLocation1) ? hsh.fetch(:startingLocation1).to_i - 1 : nil
            location_1 = if loc_1_idx
                           # Fallback in case specified index references unknown location.
                           locations_ary.fetch(loc_1_idx, :fallback)
                         else
                           :fallback
                         end
            loc_2_idx = hsh.fetch(:startingLocation2) ? hsh.fetch(:startingLocation2).to_i - 1 : nil
            location_2 = if loc_2_idx
                           # Fallback in case specified index references unknown location.
                           locations_ary.fetch(loc_2_idx, :fallback)
                         else
                           :fallback
                         end

            [
              hsh.fetch(:roundId),
              map_cache.fetch(hsh.fetch(:mapName)).id,
              map_location_cache.fetch(location_2).id,
              map_location_cache.fetch(location_1).id,
              hsh.fetch(:roundDate),
              hsh.fetch(:roundLength),
              hsh.fetch(:maxPlayers2),
              hsh.fetch(:maxPlayers1),
              hsh.fetch(:tournamentMode) == 1,

              hsh.fetch(:winningTeam),
              @server.id
            ]
          end
          Round.import(
            [
              :round_id,
              :map_id,
              :alien_starting_location_id,
              :marine_starting_location_id,
              :timestamp,
              :length,
              :max_players_aliens,
              :max_players_marines,
              :tournament_mode,
              :winning_team_id,
              :server_id
            ],
            new_round_data
          )

          @l.debug(
            {
              msg: 'Processed batch.',
              current_batch:     index + 1,
              total_batch_count: total_batch_count,
              imported_rounds:   new_round_hashes.count,
              skipped_rounds:    skipped_rounds_count
            }
          )
        end
      end

      private
      def new_rounds_in_source
        return enum_for(:new_rounds_in_source) unless block_given?

        round_info.each_page(ROUND_IMPORT_BATCH_SIZE) do |round_hashes|
          round_hashes = round_hashes.to_a

          round_ids = round_hashes.map { |hsh| hsh[:roundId] }
          existing_ids = Set.new(
            @server.
            rounds_dataset.
            where(round_id: round_ids).
            select(:round_id).
            map(&:round_id)
          )
          round_hashes.reject! { |hsh| existing_ids.include? hsh[:roundId] }

          yield(round_hashes.to_a, existing_ids.length)
        end
      end

      def round_info
        @source_db.from(:RoundInfo)
      end

      def generate_map_cache
        map_count = Map.count
        @l.debug({ msg: 'Generating round cache.' })

        cache = @source_db.from(:RoundInfo).select_map { distinct(mapName) }.map do |name|
          [name, Map.get_or_create(name)]
        end.to_h

        @l.debug({ msg: 'Map cache generated.', new_maps: Map.count - map_count })

        cache
      end

      def generate_location_cache(map_cache)
        location_count = Location.count
        @l.debug({ msg: 'Generating location cache.' })

        cache = {}

        @source_db.from(:roundInfo).select { [locationNames, mapName] }.group_by(:mapName, :locationNames).each do |hsh|
          map = map_cache.fetch(hsh.fetch(:mapName))

          # { 'location_name': Location }
          inner_hsh = JSON.parse(hsh[:locationNames]).map do |name|
            [name, Location.get_or_create(name, map: map)]
          end.to_h

          if cache.key? map.name
            inner_hsh = inner_hsh.merge(cache[map.name])
          end

          inner_hsh[:fallback] = Location.fallback(map: map)

          cache[map.name] = inner_hsh
        end

        cache
      end
    end
  end
end
