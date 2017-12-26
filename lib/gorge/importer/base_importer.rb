module Gorge
  module Importer
    class BaseImporter
      def initialize(source_db:, server:)
        @source_db = source_db
        @server    = server

        @target_db = DB

        @l = Gorge.logger(program: 'importer')
        @l.add_attribute(:server, { name: @server.name, id: @server.id })
      end
    end
  end
end
