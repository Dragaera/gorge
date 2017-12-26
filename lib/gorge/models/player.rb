# coding: utf-8

module Gorge
  class Player < Sequel::Model
    one_to_many :player_rounds
  end
end
