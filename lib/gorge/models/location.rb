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

    # Generate cache of map / location names to respective location objects.
    #
    # This does not include the fallback map which is used for rounds imported
    # before maps / locations were supported.
    def self.generate_cache
      cache = {}

      # Not including placeholder map
      Map.exclude(id: Map.placeholder.id).each do |map|
        fallback_location = fallback(map: map)

        cache[map.name] = {
          fallback: fallback_location,
        }

        # Not including fallback location as that one has a dedicated key.
        map.locations_dataset.exclude(id: fallback_location.id).each do |location|
          cache[map.name][location.name] = location
        end
      end

      cache
    end

    many_to_one :map
  end
end
