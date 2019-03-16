# coding: utf-8

module Gorge
  class Player < Sequel::Model
    one_to_many :player_rounds
    one_to_many :player_class_statistic

    # Calculate player-level statistics for all players over their last
    # `sample_size` rounds. It will calculate:
    # - KDR: Kill / death ratio.
    # - Accuracy: Percentage of total attacks which hit a target.
    # - Accuracy excluding onos hits: Percentage of total attacks which hit a
    #   non-onos target.
    #
    # For all three statistics, the divisor is clamped to `1` to prevent a
    # division by zero. This means that eg 7 kills, zero deaths will lead to a
    # KDR of 7.
    #
    # @param sample_size [Fixnum] Number of rounds which to take into account
    # for calculating player's statistics.
    #
    # @return [{Fixnum => {Fixnum => {Symbol => Object}}}]
    #   Statistics hash, of the following format:
    #       {
    #         player_id => {
    #           team_id => {
    #             kills: Fixnum,
    #             deaths: Fixnum,
    #             kdr: Float,
    #             hits: Fixnum,
    #             onos_hits: Fixnum,
    #             misses: Fixnum,
    #             accuracy: Float,
    #             accuracy_no_onos: Float,
    #             round_count: Fixnum, # Number of rounds which were used to calculate statistics
    #             to: DateTime,        # Timestamp of last round used to calculate statistics
    #             from: DateTime,      # Timestamp of first round used to calculate statistics
    #           }
    #         }
    #       }
    def self.statistics(sample_size:)
      # Will compile to something along those lines
      # SELECT 
      #     rounds.player_id, 
      #     rounds.team_id, 
      #     SUM(rounds.kills) AS kills, 
      #     SUM(rounds.deaths) AS deaths, 
      #     SUM(hits) AS hits, 
      #     SUM(onos_hits) AS onos_hits, 
      #     SUM(misses) AS misses, 
      #     COUNT(1) AS round_count, 
      #     MAX(rounds.timestamp) AS ts_to, 
      #     MIN(rounds.timestamp) AS ts_from 
      #
      # FROM (
      #     SELECT 
      #     pr.hits, 
      #     pr.misses, 
      #     pr.onos_hits, 
      #     pr.kills, 
      #     pr.deaths, 
      #     pr.player_id, 
      #     r.timestamp,
      #     row_number() OVER (
      #         PARTITION BY pr.player_id, pr.team_id 
      #         ORDER BY r.timestamp DESC
      #     ) AS round_number 
      #
      #     FROM player_rounds AS pr 
      #
      #     JOIN rounds AS r 
      #       ON r.id = pr.round_id 
      #
      #     WHERE pr.player_id < 10
      # ) AS rounds 
      #
      # WHERE rounds.round_number <= 100 
      #
      # GROUP BY rounds.player_id, rounds.team_id;

      player_rounds = PlayerRound.
        dataset.
        select { [
          :player_id,
          :kills,
          :deaths,
          :hits,
          :onos_hits,
          :misses,
          :team_id,
          Sequel[:player_rounds][:round_id],
          :timestamp,
          row_number.function.over(
            partition: :player_id,
            order: Sequel.desc(:timestamp)
          ).as(:round_number)
      ] }.
      inner_join(:rounds, id: :round_id)

      player_stats = player_rounds.
        from_self(alias: :player_rounds).
        where { round_number <= sample_size }.
        group_by([:player_id, :team_id]).
        select { [
          :player_id,
          :team_id,
          sum.function(:kills).as(:kills),
          sum.function(:deaths).as(:deaths),
          sum.function(:hits).as(:hits),
          sum.function(:onos_hits).as(:onos_hits),
          sum.function(:misses).as(:misses),
          count.function(1).as(:round_count),
          max.function(:timestamp).as(:to),
          min.function(:timestamp).as(:from)
      ] }.
      map(&:to_hash).
      group_by { |hsh| hsh[:player_id] }

      team_ids = Team.select_map(:id)

      # Now we'll have a hash of player_id => [Hash], with 1 to n hashes per
      # player.
      player_stats.each do |player_id, stats|
        stats.each do |hsh|
          kills     = hsh.fetch(:kills)
          deaths    = hsh.fetch(:deaths).nonzero? || 1

          hits          = hsh.fetch(:hits)
          onos_hits     = hsh.fetch(:onos_hits)
          misses        = hsh.fetch(:misses)
          shots         = (hits + misses).nonzero? || 1

          hsh[:kdr] = kills.to_f / deaths
          hsh[:accuracy] = hits.to_f / shots
          if hsh[:team_id] == Team::MARINES_ID
            hsh[:accuracy_no_onos] = (hits.to_f - onos_hits) / (shots - onos_hits)
          end
        end

        # We are guaranteed to only have one entry per team, as we aggregate
        # over teams.
        player_stats[player_id] = team_ids.map do |team_id|
          [
            team_id,
            stats.filter { |hsh| hsh[:team_id] == team_id }.first
          ]
        end.to_h
      end

      player_stats
    end

    def alien_rounds_dataset
      player_rounds_dataset.where(team: Team.aliens)
    end

    def marine_rounds_dataset
      player_rounds_dataset.where(team: Team.marines)
    end

    # @return [Hash] Overall and per-team KDR and accuracy.
    def statistics
      total_stats = player_rounds_dataset.
        select {
          [
            (sum(hits).cast(:float) / Sequel.case({ { (sum(hits) + sum(misses)) => 0 } => 1 }, sum(hits) + sum(misses))).as(accuracy),
            (sum(kills).cast(:float) / Sequel.case({ { sum(:deaths) => 0 } => 1 }, sum(:deaths))).as(kdr),
          ]
      }.first

      alien_stats = alien_rounds_dataset.
        select {
          [
            (sum(hits).cast(:float) / Sequel.case({ { (sum(hits) + sum(misses)) => 0 } => 1 }, sum(hits) + sum(misses))).as(accuracy),
            (sum(kills).cast(:float) / Sequel.case({ { sum(:deaths) => 0 } => 1 }, sum(:deaths))).as(kdr),
          ]
      }.first

      marine_stats = marine_rounds_dataset.
        select {
          [
            (sum(hits).cast(:float) / Sequel.case({ { (sum(hits) + sum(misses)) => 0 } => 1 }, sum(hits) + sum(misses))).as(accuracy),
            (sum(kills).cast(:float) / Sequel.case({ { sum(:deaths) => 0 } => 1 }, sum(:deaths))).as(kdr),
            ((sum(hits).cast(:float) - sum(onos_hits)) / Sequel.case({ { (sum(hits) - sum(onos_hits) + sum(misses)) => 0 } => 1 }, sum(hits) - sum(onos_hits) + sum(misses))).as(accuracy_no_onos),
          ]
      }.first

      {
        steam_id: steam_id,
        kdr: {
          total:  total_stats[:kdr],
          alien:  alien_stats[:kdr],
          marine: marine_stats[:kdr],
        },
        accuracy: {
          total: total_stats[:accuracy],
          alien: alien_stats[:accuracy],
          marine: {
            total:   marine_stats[:accuracy],
            no_onos: marine_stats[:accuracy_no_onos],
          }
        }
      }
    end

    # @return [Float] Overall accuracy.
    def accuracy
      player_rounds_dataset.
        select_map {
          sum(hits).cast(:float) / Sequel.case({ { (sum(hits) + sum(misses)) => 0 } => 1 }, sum(hits) + sum(misses))
      }.first
    end

    # @return [Float] Alien accuracy.
    def alien_accuracy
      alien_rounds_dataset.
        select_map {
          sum(hits).cast(:float) / Sequel.case({ { (sum(hits) + sum(misses)) => 0 } => 1 }, sum(hits) + sum(misses))
      }.first
    end

    # @param [TrueClass] include_onos Whether to include onos hits in accuracy.
    # @return [Float] Marine accuracy.
    def marine_accuracy(include_onos: true)
      if include_onos
        marine_rounds_dataset.
          select_map {
            sum(hits).cast(:float) / Sequel.case({ { (sum(hits) + sum(misses)) => 0 } => 1 }, sum(hits) + sum(misses))
        }.first
      else
        marine_rounds_dataset.
          select_map {
            (sum(hits).cast(:float) - sum(onos_hits)) / Sequel.case({ { (sum(hits) - sum(onos_hits) + sum(misses)) => 0 } => 1 }, sum(hits) - sum(onos_hits) + sum(misses))
        }.first
      end
    end

    # @return [Float] Overall KDR.
    def kdr
      player_rounds_dataset.
        select_map {
          sum(kills).cast(:float) / Sequel.case({ { sum(:deaths) => 0 } => 1 }, sum(:deaths))
      }.first
    end

    # @return [Float] Alien KDR.
    def alien_kdr
      alien_rounds_dataset.
        select_map {
          sum(kills).cast(:float) / Sequel.case({ { sum(:deaths) => 0 } => 1 }, sum(:deaths))
      }.first
    end

    # @return [Float] Marine KDR.
    def marine_kdr
      marine_rounds_dataset.
        select_map {
          sum(kills).cast(:float) / Sequel.case({ { sum(:deaths) => 0 } => 1 }, sum(:deaths))
      }.first
    end
  end
end
