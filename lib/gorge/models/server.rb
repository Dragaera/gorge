# coding: utf-8

module Gorge
  class Server < Sequel::Model
    one_to_many :rounds
    one_to_many :data_sources
  end
end
