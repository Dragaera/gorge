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
        PlayerStatisticsClass.each do |cls|
          @logger.add_attribute(:player_statistics_class, cls.name)
          @logger.add_attribute(:sample_size, cls.sample_size)
          @logger.info({ msg:'Generating player statistics.' })

          player_statistics = Player.statistics(sample_size: 100)

          tuples = self.prepare_tuples(player_statistics, statistics_class: cls)
          self.insert_tuples(tuples)
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

      def self.insert_tuples(tuples)
        tuples_length = tuples.length
        batch_count = (tuples_length.to_f / BULK_IMPORT_BATCH_SIZE).ceil
        @logger.debug({
          msg: 'Inserting player statistics.',
          player_statistics_count: tuples_length,
          batch_size: BULK_IMPORT_BATCH_SIZE
        })

        tuples.each_slice(BULK_IMPORT_BATCH_SIZE).each_with_index do |slice, index|
          PlayerStatistics.import(
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
          @logger.debug({
            msg: 'Processed batch.',
            current_batch: index + 1,
            total_batch_count: batch_count
          })
        end
      end
    end
  end
end
