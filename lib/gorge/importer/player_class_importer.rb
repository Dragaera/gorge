module Gorge
  module Importer
    class PlayerClassImporter < BaseImporter
      PLAYER_CLASS_STATS_IMPORT_BATCH_SIZE = 10_000

      def initialize(*args, **kwargs)
        super(*args, **kwargs)

        @l.module = 'player_classes'
      end

      def import
        player_id_map = Player.select_map([:steam_id, :id]).to_h
        round_id_map  = @server.rounds_dataset.select_map([:round_id, :id]).to_h
        class_id_map  = PlayerClass.select_map([:name, :id]).to_h

        player_class_stats_count = player_class_stats.count

        total_batch_count = (player_class_stats_count.to_f / PLAYER_CLASS_STATS_IMPORT_BATCH_SIZE).ceil
        @l.debug({ msg: 'Starting import.', player_class_stats_count: player_class_stats_count, batch_size: PLAYER_CLASS_STATS_IMPORT_BATCH_SIZE })

        new_player_class_stats_in_source.each_with_index do |args, index|
          # TODO: This can't be the proper way
          new_player_class_stats_hashes, skipped_player_class_stats_count = *args

          # roundId, steamId, class, classTime
          new_player_class_stats_data = new_player_class_stats_hashes.map do |hsh|
            [
              player_id_map.fetch(hsh.fetch(:steamId)),
              round_id_map.fetch(hsh.fetch(:roundId)),
              class_id_map.fetch(hsh.fetch(:class)),

              hsh.fetch(:classTime),
            ]
          end

          PlayerClassStatistic.import(
            [
              :player_id,
              :round_id,
              :player_class_id,

              :time_played,
            ],
            new_player_class_stats_data
          )

          @l.debug(
            {
              msg:                         'Processed batch.',
              current_batch:               index + 1,
              total_batch_count:           total_batch_count,
              imported_player_class_stats: new_player_class_stats_hashes.count,
              skipped_player_class_stats:  skipped_player_class_stats_count
            }
          )
        end
      end

      private
      def new_player_class_stats_in_source
        return enum_for(:new_player_class_stats_in_source) unless block_given?

        existing_player_class_stats_tuples = Set.new(
          PlayerClassStatistic.
          graph(:players, { id: :player_id }, join_type: :inner).
          graph(:rounds, { id: Sequel[:player_class_statistics][:round_id] }, join_type: :inner).
          graph(:player_classes, { id: Sequel[:player_class_statistics][:player_class_id] }, join_type: :inner).
          graph(:servers, { id: Sequel[:rounds][:server_id] }, join_type: :inner).
          where(Sequel[:servers][:id] => @server.id).
          select(Sequel[:rounds][:round_id], Sequel[:players][:steam_id], Sequel[:player_classes][:name]).
          map { |join_obj| [join_obj[:round_id], join_obj[:steam_id], join_obj[:name]] }
        )

        player_class_stats.each_page(PLAYER_CLASS_STATS_IMPORT_BATCH_SIZE) do |player_class_stats_hashes|
          rejected_data, new_data = player_class_stats_hashes.partition do |hsh|
            existing_player_class_stats_tuples.include?(
              [hsh.fetch(:roundId), hsh.fetch(:steamId), hsh.fetch(:class)]
            )
          end

          yield(new_data, rejected_data.count)
        end
      end

      def player_class_stats
        @source_db.from(:PlayerClassStats)
      end
    end
  end
end
