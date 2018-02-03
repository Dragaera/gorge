# coding: utf-8

module Gorge
  class Team < Sequel::Model
    one_to_many :rounds, key: :winning_team_id
    one_to_many :player_rounds

    def self.draw
      Team[0]
    end

    def self.marines
      Team[1]
    end

    def self.aliens
      Team[2]
    end
  end
end
