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
      result = player_rounds_dataset.
        select {
          [
            sum(hits).as(hits),
            sum(misses).as(misses)
          ]
        }.first

      shots = result[:hits] + result[:misses]
      result[:hits] / shots.to_f
    end

    # @return [Float] Alien accuracy.
    def alien_accuracy
      result = alien_rounds_dataset.
        select {
          [
            sum(hits).as(hits),
            sum(misses).as(misses)
          ]
        }.first

      shots = result[:hits] + result[:misses]
      result[:hits] / shots.to_f
    end

    # @param [TrueClass] include_onos Whether to include onos hits in accuracy.
    # @return [Float] Marine accuracy.
    def marine_accuracy(include_onos: true)
      result = marine_rounds_dataset.
        select {
          [
            sum(hits).as(hits),
            sum(onos_hits).as(onos_hits),
            sum(misses).as(misses)
          ]
        }.first

      hits  = result[:hits]
      shots = hits + result[:misses]

      if include_onos
        hits / shots.to_f
      else
        (hits - result[:onos_hits]) / (shots.to_f - result[:onos_hits])
      end
    end

    # @return [Float] Overall KDR.
    def kdr
      player_rounds_dataset.sum(:kills).to_f / player_rounds_dataset.sum(:deaths)
    end

    # @return [Float] Alien KDR.
    def alien_kdr
      alien_rounds_dataset.sum(:kills).to_f / alien_rounds_dataset.sum(:deaths)
    end

    # @return [Float] Marine KDR.
    def marine_kdr
      marine_rounds_dataset.sum(:kills).to_f / marine_rounds_dataset.sum(:deaths)
    end
  end
end
