# coding: utf-8

module Gorge
  class PlayerClass < Sequel::Model
    one_to_many :player_class_statistic
  end
end

