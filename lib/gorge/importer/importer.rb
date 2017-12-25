module Gorge
  module Importer
    class Importer
      def initialize(source_file)
        @source_file = source_file

        @player_importer = PlayerImporter.new(@source_file)
      end

      def import
        @player_importer.import
      end
    end
  end
end
