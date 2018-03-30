module Gorge
  module Config
    module Database
      def self.database
        opts = {}
        opts[:adapter]  = ADAPTER
        opts[:host]     = HOST     if HOST
        opts[:port]     = PORT     if PORT
        opts[:database] = DATABASE if DATABASE
        opts[:user]     = USER     if USER
        opts[:password] = PASS     if PASS
        opts[:test]     = true
        opts[:logger]   = Gorge.logger(program: 'sequel')

        Sequel.connect(opts)
      end
    end
  end
end

# Eh? `config/boot` rather?
STDOUT.sync = true

# Needs to be loaded when `pg_enum` extension is loaded, for its methods to be
# available directly within migration blocks.
Sequel.extension :migration
Sequel::Database.extension(:pagination)

# Automated created at / updated at timestamps.
Sequel::Model.plugin :timestamps

DB = Gorge::Config::Database.database
# We only want to load this for our main (Postgres) database, and *not* for all
# databases, as they might be SQLite ones in case of importers.
DB.extension(:pg_enum)
Sequel::Model.db = DB

begin
  DatabaseCleaner[:sequel].db = DB
rescue NameError
end
