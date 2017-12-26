module Gorge
  module Importer
    class Importer
      def initialize(source_file, server:)
        @source_db = Sequel.connect("sqlite://#{ source_file }", readonly: true)
        @source_db.extension(:pagination)

        @server = server

        @round_importer  = RoundImporter.new(source_db: @source_db, server: server)
        @player_importer = PlayerImporter.new(source_db: @source_db)
      end

      def import
        @round_importer.import
        @player_importer.import
      end
    end
  end
end
