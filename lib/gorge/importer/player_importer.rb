module Gorge
  module Importer
    class PlayerImporter < BaseImporter
      PLAYER_IMPORT_BATCH_SIZE = 10_000

      def initialize(*args, **kwargs)
        super(*args, **kwargs)

        @l.module = 'players'
      end

      def import
        player_id_count = player_round_stats.distinct.select(:steamId).count

        total_batch_count = (player_id_count.to_f / PLAYER_IMPORT_BATCH_SIZE).ceil
        @l.debug({ msg: 'Starting import.', player_id_count: player_id_count, batch_size: PLAYER_IMPORT_BATCH_SIZE })

        new_player_ids_in_source.each_with_index do |args, index|
          # TODO: This can't be the proper way
          batch_ids, skipped_ids = *args
          Player.import([:steam_id], batch_ids)

          @l.debug(
            {
              msg: 'Processed batch.',
              current_batch: index + 1,
              total_batch_count: total_batch_count,
              imported_ids: batch_ids.count,
              skipped_ids:  skipped_ids.count
            }
          )
        end
      end

      private
      def new_player_ids_in_source
        return enum_for(:new_player_ids_in_source) unless block_given?

        player_round_stats.distinct.select(:steamId).each_page(PLAYER_IMPORT_BATCH_SIZE) do |id_ds|
          new_ids_in_batch = id_ds.map { |hsh| hsh[:steamId] }
          existing_ids = Player.where(steam_id: new_ids_in_batch).select_map(:steam_id)
          new_ids_in_batch -= existing_ids

          yield(new_ids_in_batch, existing_ids)
        end
      end

      def player_round_stats
        @source_db.from(:PlayerRoundStats)
      end
    end
  end
end
