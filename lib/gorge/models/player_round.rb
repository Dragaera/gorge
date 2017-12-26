# coding: utf-8

module Gorge
  class PlayerRound < Sequel::Model
    many_to_one :player
    many_to_one :round
    many_to_one :team
  end
end
