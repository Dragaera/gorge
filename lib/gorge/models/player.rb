# coding: utf-8

module Gorge
  class Player < Sequel::Model
    one_to_many :player_rounds

    def accuracy
      rslt = player_rounds_dataset.
        where(team_id: 1).
        select {
          [
            sum(hits).as(marine_hits),
            sum(onos_hits).as(marine_onos_hits),
            sum(misses).as(marine_misses)
          ]
        }.
        first
      marine_hits = rslt[:marine_hits]
      marine_onos_hits = rslt[:marine_onos_hits]
      marine_misses = rslt[:marine_misses]
      marine_shots = marine_hits + marine_misses

      rslt = player_rounds_dataset.
        where(team_id: 2).
        select {
          [
            sum(hits).as(alien_hits),
            sum(misses).as(alien_misses)
          ]
        }.
        first
      alien_hits = rslt[:alien_hits]
      alien_misses = rslt[:alien_misses]
      alien_shots = alien_hits + alien_misses

      {
        marine_total: marine_hits / marine_shots.to_f,
        marine_noonos: (marine_hits - marine_onos_hits) / (marine_shots.to_f - marine_onos_hits),
        alien: alien_hits / alien_shots.to_f
      }
    end

    def kdr(team: :both)
      if team == :both
        player_rounds_dataset.sum(:kills).to_f / player_rounds_dataset.sum(:deaths)
      elsif team == :marines
        player_rounds_dataset.where(team_id: 1).sum(:kills).to_f / player_rounds_dataset.where(team_id: 1).sum(:deaths)
      elsif team == :aliens
        player_rounds_dataset.where(team_id: 2).sum(:kills).to_f / player_rounds_dataset.where(team_id: 2).sum(:deaths)
      end
    end
  end
end
