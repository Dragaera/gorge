module Gorge
  module Importer
    class Importer
      def initialize(source_file, server:)
        @source_file = source_file
        @server = server

        @round_importer  = RoundImporter.new(@source_file, server: server)
        @player_importer = PlayerImporter.new(@source_file)
      end

      def import
        @round_importer.import
        @player_importer.import
      end
    end
  end
end
