module Gorge
  class PlayerCurrentStatistics < Sequel::Model
    many_to_one :player
    many_to_one :team
    many_to_one :player_statistics_class

    many_to_one :player_statistics, class: 'Gorge::PlayerStatistics'

    def self.lookup(player:, statistics_class:, team:)
      current_statistics = first(
        player: player,
        player_statistics_class: statistics_class,
        team: team
      )

      if current_statistics
        current_statistics.player_statistics
      else
        nil
      end
    end
  end
end

