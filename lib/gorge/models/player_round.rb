# coding: utf-8

module Gorge
  class PlayerRound < Sequel::Model
    many_to_one :player
    many_to_one :round
    many_to_one :team

    def ==(other)
      other.class == PlayerRound &&
        other.player_id == player_id &&
        other.round_id == round_id &&
        other.team_id == team_id &&
        other.time_played == time_played &&
        other.time_building == time_building &&
        other.time_commander == time_commander &&
        other.kills == kills &&
        other.assists == assists &&
        other.deaths == deaths &&
        other.killstreak == killstreak &&
        other.hits == hits &&
        other.onos_hits == onos_hits &&
        other.misses == misses &&
        other.player_damage == player_damage &&
        other.structure_damage == structure_damage &&
        other.score == score
    end
  end
end
