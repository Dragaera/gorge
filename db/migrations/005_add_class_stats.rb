Sequel.migration do
  up do
    create_table :player_classes do
      primary_key :id

      String :name, null: false, unique: true

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :update_at
    end
    [
      'Dead', 'Flamethrower', 'Rifle', 'Shotgun', 'Embryo', 'Skulk', 'Fade',
      'Lerk', 'Onos', 'Commander', 'Exo', 'Void', 'GrenadeLauncher', 'Gorge',
      'HeavyMachineGun'
    ].each do |cls|
      from(:player_classes).insert(name: cls)
    end

    create_table :player_class_statistics do
      primary_key :id

      foreign_key :player_id,        null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :round_id,         null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :player_class_id,  null: false, on_update: :cascade, on_delete: :restrict

      Float :time_played, null: false

      unique [:player_id, :round_id, :player_class_id]
    end
  end

  down do
    drop_table :player_class_statistics
    drop_table :player_classes
  end
end
