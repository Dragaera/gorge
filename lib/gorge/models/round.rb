# coding: utf-8

module Gorge
  class Round < Sequel::Model
    many_to_one :alien_starting_location, class: 'Gorge::Location'
    many_to_one :marine_starting_location, class: 'Gorge::Location'
    many_to_one :map
    one_to_many :player_rounds
    one_to_many :player_class_statistic
    many_to_one :server
    many_to_one :winning_team, class: :'Gorge::Team'
  end
end
