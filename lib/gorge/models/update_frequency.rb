# coding: utf-8

module Gorge
  class UpdateFrequency < Sequel::Model
    one_to_many :data_sources
  end
end
