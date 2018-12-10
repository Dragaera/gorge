module Gorge
  class Location < Sequel::Model
    def self.get_or_create(name, map:)
      location = first(name: name, map: map)
      if location
        location
      else
        create(name: name, map: map)
      end
    end

    def self.fallback(map: )
      get_or_create('UNDEFINED', map: map)
    end

    many_to_one :map
  end
end
