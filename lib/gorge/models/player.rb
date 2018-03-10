# coding: utf-8

module Gorge
  class Player < Sequel::Model
    one_to_many :player_rounds

    def alien_rounds_dataset
      player_rounds_dataset.where(team: Team.aliens)
    end

    def marine_rounds_dataset
      player_rounds_dataset.where(team: Team.marines)
    end

    # @return [Float] Overall accuracy.
    def accuracy
      player_rounds_dataset.
        select_map {
          sum(hits).cast(:float) / (sum(hits) + sum(misses))
      }.first
    end

    # @return [Float] Alien accuracy.
    def alien_accuracy
      alien_rounds_dataset.
        select_map {
          sum(hits).cast(:float) / (sum(hits) + sum(misses))
      }.first
    end

    # @param [TrueClass] include_onos Whether to include onos hits in accuracy.
    # @return [Float] Marine accuracy.
    def marine_accuracy(include_onos: true)
      if include_onos
        marine_rounds_dataset.
          select_map {
            sum(hits).cast(:float) / (sum(hits) + sum(misses))
        }.first
      else
        marine_rounds_dataset.
          select_map {
            (sum(hits).cast(:float) - sum(onos_hits)) / (sum(hits) - sum(onos_hits) + sum(misses))
        }.first
      end
    end

    # @return [Float] Overall KDR.
    def kdr
      player_rounds_dataset.
        select_map {
          sum(kills).cast(:float) / sum(deaths)
      }.first
    end

    # @return [Float] Alien KDR.
    def alien_kdr
      alien_rounds_dataset.
        select_map {
          sum(kills).cast(:float) / sum(deaths)
      }.first
    end

    # @return [Float] Marine KDR.
    def marine_kdr
      marine_rounds_dataset.
        select_map {
        sum(kills).cast(:float) / sum(deaths)
      }.first
    end
  end
end
