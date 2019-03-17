module Gorge
  class PlayerStatisticsClass < Sequel::Model
    one_to_many :player_statistics,         class: 'Gorge::PlayerStatistics'
    one_to_many :player_current_statistics, class: 'Gorge::PlayerCurrentStatistics'

    def self.active
      dataset.
        where(enabled: true)
    end
  end
end

