module Gorge
  class PlayerStatistics < Sequel::Model
    many_to_one :player
    many_to_one :team
    many_to_one :player_statistics_class

    one_to_many :player_current_statistics, class: 'Gorge::PlayerCurrentStatistics'
  end
end

