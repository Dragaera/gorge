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

DB = Sequel.connect(opts)
Sequel::Database.extension(:pagination)
Sequel::Model.db = DB
