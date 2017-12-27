# coding: utf-8

module Gorge
  class Team < Sequel::Model
    one_to_many :rounds, key: :winning_team_id
    one_to_many :player_rounds
  end
end
