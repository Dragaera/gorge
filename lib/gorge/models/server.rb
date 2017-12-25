# coding: utf-8

module Gorge
  class Server < Sequel::Model
    one_to_many :rounds
  end
end
