module Gorge
  class PlayerStatistics < Sequel::Model
    many_to_one :player
    many_to_one :team

  end
end

