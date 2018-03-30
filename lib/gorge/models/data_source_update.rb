# coding: utf-8

module Gorge
  class DataSourceUpdate < Sequel::Model
    many_to_one :data_source
  end
end
