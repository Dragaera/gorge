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
        round_count = round_info.count

        total_batch_count = (round_count.to_f / ROUND_IMPORT_BATCH_SIZE).ceil
        @l.debug({ msg: 'Starting import.', round_count: round_count, batch_size: ROUND_IMPORT_BATCH_SIZE })

        new_rounds_in_source.each_with_index do |args, index|
          # TODO: This can't be the proper way
          new_round_hashes, skipped_rounds_count = *args

          new_round_data = new_round_hashes.map do |hsh|
            [
              hsh.fetch(:roundId),
              hsh.fetch(:roundDate),
              hsh.fetch(:maxPlayers1),
              hsh.fetch(:maxPlayers2),
              hsh.fetch(:tournamentMode) == 1,

              hsh.fetch(:winningTeam),
              @server.id
            ]
          end
          Round.import(
            [
              :round_id,
              :timestamp,
              :max_players_marines,
              :max_players_aliens,
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
    end
  end
end
