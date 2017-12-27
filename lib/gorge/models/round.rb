# coding: utf-8

module Gorge
  class Round < Sequel::Model
    many_to_one :server
    many_to_one :winning_team, class: :'Gorge::Team'
    one_to_many :player_rounds
  end
end
