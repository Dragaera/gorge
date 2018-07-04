# coding: utf-8

module Gorge
  class PlayerClassStatistic < Sequel::Model
    many_to_one :player
    many_to_one :round
    many_to_one :player_class
  end
end

