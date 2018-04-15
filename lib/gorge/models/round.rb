# coding: utf-8

module Gorge
  class Round < Sequel::Model
    many_to_one :map
    one_to_many :player_rounds
    many_to_one :server
    many_to_one :winning_team, class: :'Gorge::Team'
  end
end
