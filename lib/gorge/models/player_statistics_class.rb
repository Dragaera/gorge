module Gorge
  class PlayerStatisticsClass < Sequel::Model
    one_to_many :player_statistics, class: 'Gorge::PlayerStatistics'

  end
end

