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

    one_to_many :rounds
  end
end
