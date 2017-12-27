namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    # Don't load models when executing DB migrations.
    # This is required, since some of the tables they refer to might not exist
    # yet. It also prevents accidentally using them within migrations - which
    # is asking for trouble anyway.
    ENV['GORGE_SKIP_MODELS'] = '1'
    require 'config/boot'

    Sequel.extension :migration
    db = Sequel::Model.db
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, "db/migrations", target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(db, "db/migrations")
    end
  end
end
