module Gorge
  module Jobs
    # Generates a new player statistics data point for each player.
    class UpdatePlayerStatistics
      extend Resque::Plugins::JobStats

      BULK_IMPORT_BATCH_SIZE = 10_000

      @queue = :update_player_statistics
      @durations_recorded = ::Gorge::Config::Resque::DURATIONS_RECORDED

      @logger = Gorge.logger(program: 'update_player_statistics')

      def self.perform
        PlayerStatisticsClass.active.each do |cls|
          @logger.add_attribute(:player_statistics_class, cls.name)
          @logger.add_attribute(:sample_size, cls.sample_size)
          @logger.info({ msg:'Generating player statistics.' })
player_statistics = Player.statistics(sample_size: cls.sample_size)

          tuples = self.prepare_tuples(player_statistics, statistics_class: cls)
          tuples = self.remove_unchanged_tuples(tuples, statistics_class: cls)

          new_pks = self.insert_tuples(tuples)

          self.update_statistics_lookup_table(new_pks)
        end
        @logger.info({ msg: 'Finished generating player statistics.' })
      end

      def self.prepare_tuples(player_statistics, statistics_class:)
        @logger.debug({ msg: 'Preparing tuples.' })
        marines_team_id = Team.marines.id
        tuples = player_statistics.map do |player_id, player_hsh|
          player_hsh.map do |team_id, team_hsh|
            # Will leave a `nil` in the result which we have to get rid of
            # afterwards.
            next if team_hsh.nil?
            [
              player_id,
              team_id,
              statistics_class.id,
              team_hsh.fetch(:kills),
              team_hsh.fetch(:deaths),
              team_hsh.fetch(:kdr),
              team_hsh.fetch(:hits),
              team_hsh.fetch(:onos_hits),
              team_hsh.fetch(:misses),
              team_hsh.fetch(:accuracy),
              team_id == marines_team_id ? team_hsh.fetch(:accuracy_no_onos) : nil,
              team_hsh.fetch(:round_count),
              team_hsh.fetch(:from),
              team_hsh.fetch(:to),
            ]
          end.
          compact # Get rid of `nil` mentioned above
        end.
        # Remove double nesting of players which resulted from player_id -> team_id nesting.
        flatten(1)

        tuples
      end

      def self.remove_unchanged_tuples(tuples, statistics_class:)
        player_ids = tuples.map { |ary| ary[0] }
        team_ids   = tuples.map { |ary| ary[1] }
        class_ids  = [statistics_class.id] * tuples.length
        to_timestamps = tuples.map { |ary| ary[13] }
        new_identities = Set.new(player_ids.zip(team_ids, class_ids, to_timestamps))

        db = Sequel::Model.db
        existing_identities = Set.new(
          db.
          from(:player_current_statistics).
          select(
            :player_id,
            :team_id,
            :player_statistics_class_id,
          ).
          graph(
            :player_statistics,
            { id: :player_statistics_id },
            join_type: :inner,
            select: [:to]
          ).select_map(
            [
              Sequel[:player_current_statistics][:player_id],
              Sequel[:player_current_statistics][:team_id],
              Sequel[:player_current_statistics][:player_statistics_class_id],
              :to,
            ]
          )
        )

        # (player_id, team_id, class_id, to_timestamp) tuples which have changed or do not exist yet.
        changed_identities = new_identities - existing_identities

        tuple_count_before = tuples.length
        tuples = tuples.select do |ary|
          identity = [ary[0], ary[1], statistics_class.id, ary[13]]
          changed_identities.include? identity
        end
        tuple_count_after = tuples.length

        @logger.debug({
          msg: 'Removed unchanged tuples.',
          tuple_count_before: tuple_count_before,
          tuple_count_after: tuple_count_after,
        })

        tuples
      end

      def self.insert_tuples(tuples)
        new_pks = []

        tuples_length = tuples.length
        batch_count = (tuples_length.to_f / BULK_IMPORT_BATCH_SIZE).ceil
        @logger.debug({
          msg: 'Inserting player statistics.',
          player_statistics_count: tuples_length,
          batch_size: BULK_IMPORT_BATCH_SIZE
        })

        tuples.each_slice(BULK_IMPORT_BATCH_SIZE).each_with_index do |slice, index|
          pks = PlayerStatistics.
            dataset.
            returning(:id).
            import(
              [
                :player_id,
                :team_id,
                :player_statistics_class_id,
                :kills,
                :deaths,
                :kdr,
                :hits,
                :onos_hits,
                :misses,
                :accuracy,
                :accuracy_no_onos,
                :round_count,
                :from,
                :to,
              ],
              slice
            )

          new_pks += pks
          @logger.debug({
            msg: 'Processed batch.',
            current_batch: index + 1,
            total_batch_count: batch_count
          })
        end

        new_pks
      end

      # Updates the statistics lookup table, setting each current statistics
      # reference for those player statistics which have been inserted.
      #
      # Rather than doing single updates - which might take a long time if
      # there were a lot of new player statistics - this is done via an upsert.
      #
      # This both ensure that new entries are created and existing ones
      # updated, as well as being extremely performant as the data for the
      # newly inserted tuples is fetched directly from the database.
      def self.update_statistics_lookup_table(new_pks)
        # INSERT INTO players_current_statistics AS pcs (
        #   player_statistics_id,
        #   player_id,
        #   team_id,
        #   player_statistics_class_id
        # ) 
        #
        # SELECT DISTINCT 
        #   ON(
        #     s.player_id,
        #     s.team_id,
        #     s.player_statistics_class_id
        #   ) 
        #   s.id,
        #   s.player_id,
        #   s.team_id,
        #   s.player_statistics_class_id 
        #
        # FROM player_statistics AS s
        #
        # ORDER BY 
        #   s.player_id,
        #   s.team_id,
        #   s.player_statistics_class_id,
        #   s.to 
        #   DESC 
        #
        # ON CONFLICT (
        #   player_id,
        #   team_id,
        #   player_statistics_class_id
        # ) 
        #
        # DO UPDATE SET 
        #   player_statistics_id = EXCLUDED.player_statistics_id 
        #
        #   WHERE pcs.player_statistics_id != EXCLUDED.player_statistics_id;

        @logger.debug({ msg: 'Updating statistics lookup table.', changed_tuples: new_pks.length })
        return if new_pks.empty?

        new_statistics = PlayerStatistics.
          dataset.
          where(id: new_pks).
          select(
            :id,
            :player_id,
            :team_id,
            :player_statistics_class_id,
        )

        db = Sequel::Model.db
        db[:player_current_statistics].
          insert_conflict(
            target: [
              :player_id,
              :team_id,
              :player_statistics_class_id,
            ],
            update: {
              player_statistics_id: Sequel[:excluded][:player_statistics_id],
            },
            update_where: Sequel.~({
                Sequel[:player_current_statistics][:player_statistics_id] => Sequel[:excluded][:player_statistics_id]
            })
          ).
          import(
            [
              :player_statistics_id,
              :player_id,
              :team_id,
              :player_statistics_class_id
            ],
            new_statistics
          )
      end
    end
  end
end
