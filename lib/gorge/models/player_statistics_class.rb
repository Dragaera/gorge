module Gorge
  class PlayerStatisticsClass < Sequel::Model
    one_to_many :player_statistics, class: 'Gorge::PlayerStatistics'

    def self.active
      dataset.
        where(enabled: true)
    end
  end
end

