# coding: utf-8

module Gorge
  class Team < Sequel::Model
    DRAW_ID    = 0
    MARINES_ID = 1
    ALIENS_ID  = 2

    one_to_many :rounds, key: :winning_team_id
    one_to_many :player_rounds

    def self.draw
      Team[DRAW_ID]
    end

    def self.marines
      Team[MARINES_ID]
    end

    def self.aliens
      Team[ALIENS_ID]
    end
  end
end
