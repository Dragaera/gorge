module Gorge
  module Importer
    class PlayerRoundImporter < BaseImporter
      PLAYER_ROUNDS_IMPORT_BATCH_SIZE = 10_000

      def initialize(*args, **kwargs)
        super(*args, **kwargs)

        @l.module = 'player_rounds'
      end

      def import
        player_id_map = Player.select_map([:steam_id, :id]).to_h
        round_id_map  = @server.rounds_dataset.select_map([:round_id, :id]).to_h

        player_rounds_count = player_rounds_stats.count

        total_batch_count = (player_rounds_count.to_f / PLAYER_ROUNDS_IMPORT_BATCH_SIZE).ceil
        @l.debug({ msg: 'Starting import.', player_rounds_count: player_rounds_count, batch_size: PLAYER_ROUNDS_IMPORT_BATCH_SIZE })

        new_player_rounds_in_source.each_with_index do |args, index|
          # TODO: This can't be the proper way
          new_player_rounds_hashes, skipped_player_rounds_count = *args

          new_player_rounds_data = new_player_rounds_hashes.map do |hsh|
            [
              player_id_map.fetch(hsh.fetch(:steamId)),
              round_id_map.fetch(hsh.fetch(:roundId)),
              hsh.fetch(:teamNumber),

              hsh.fetch(:timePlayed),
              hsh.fetch(:timeBuilding),
              hsh.fetch(:commanderTime),
              hsh.fetch(:kills),
              hsh.fetch(:assists),
              hsh.fetch(:deaths),
              hsh.fetch(:killstreak),
              hsh.fetch(:hits),
              hsh.fetch(:onosHits),
              hsh.fetch(:misses),
              hsh.fetch(:playerDamage),
              hsh.fetch(:structureDamage),
              hsh.fetch(:score),
            ]
          end

          PlayerRound.import(
            [
              :player_id,
              :round_id,
              :team_id,

              :time_played,
              :time_building,
              :time_commander,
              :kills,
              :assists,
              :deaths,
              :killstreak,
              :hits,
              :onos_hits,
              :misses,
              :player_damage,
              :structure_damage,
              :score
            ],
            new_player_rounds_data
          )

          @l.debug(
            {
              msg:                    'Processed batch.',
              current_batch:          index + 1,
              total_batch_count:      total_batch_count,
              imported_player_rounds: new_player_rounds_hashes.count,
              skipped_player_rounds:  skipped_player_rounds_count
            }
          )
        end
      end

      private
      def new_player_rounds_in_source
        return enum_for(:new_player_rounds_in_source) unless block_given?

        existing_player_round_tuples = Set.new(
          PlayerRound.
          graph(:players, { id: :player_id }, join_type: :inner).
          graph(:rounds, { id: Sequel[:player_rounds][:round_id] }, join_type: :inner).
          graph(:servers, { id: :server_id }, join_type: :inner).
          where(Sequel[:servers][:id] => @server.id).
          select_map([Sequel[:rounds][:round_id], Sequel[:players][:steam_id], Sequel[:player_rounds][:team_id]])
        )

        player_rounds_stats.each_page(PLAYER_ROUNDS_IMPORT_BATCH_SIZE) do |player_rounds_hashes|
          rejected_data, new_data = player_rounds_hashes.partition do |hsh|
            existing_player_round_tuples.include?(
              [hsh.fetch(:roundId), hsh.fetch(:steamId), hsh.fetch(:teamNumber)]
            )
          end

          yield(new_data, rejected_data.count)
        end
      end

      def player_rounds_stats
        @source_db.from(:PlayerRoundStats)
      end
    end
  end
end
