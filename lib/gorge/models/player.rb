# coding: utf-8

module Gorge
  class Player < Sequel::Model
    one_to_many :player_rounds
    one_to_many :player_class_statistic

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
