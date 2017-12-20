namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
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
