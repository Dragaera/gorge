opts = {}
opts[:adapter]  = Gorge::Config::Database::ADAPTER
opts[:host]     = Gorge::Config::Database::HOST     if Gorge::Config::Database::HOST
opts[:port]     = Gorge::Config::Database::PORT     if Gorge::Config::Database::PORT
opts[:database] = Gorge::Config::Database::DATABASE if Gorge::Config::Database::DATABASE
opts[:user]     = Gorge::Config::Database::USER     if Gorge::Config::Database::USER
opts[:password] = Gorge::Config::Database::PASS     if Gorge::Config::Database::PASS
opts[:test]     = true
opts[:logger]   = Gorge.logger(program: 'sequel')

STDOUT.sync = true

# Needs to be loaded when `pg_enum` extension is loaded, for its methods to be
# available directly within migration blocks.
Sequel.extension :migration
Sequel::Database.extension(:pagination)

DB = Sequel.connect(opts)
# We only want to load this for our main (Postgres) database, and *not* for all
# databases, as they might be SQLite ones in case of importers.
DB.extension(:pg_enum)
Sequel::Model.db = DB

begin
  DatabaseCleaner[:sequel].db = DB
rescue NameError
end
