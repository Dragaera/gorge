module Gorge
  class Map < Sequel::Model
    def self.get_or_create(name)
      map = first(name: name)
      if map
        map
      else
        create(name: name)
      end
    end

    # Placeholder map which is assigned to rounds which were imported before
    # support for maps & locations was added.
    def self.placeholder
      first(name: 'gorge_placeholder')
    end

    def self.generate_cache
      Map.exclude(id: placeholder.id).map do |map|
        [map.name, map]
      end.to_h
    end

    one_to_many :rounds
    one_to_many :locations
  end
end
