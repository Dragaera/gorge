Sequel.migration do
  up do
    alter_table :rounds do
      add_column :length, Integer
    end

    create_table :maps do
      primary_key :id

      String :name, null: false, unique: true

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :update_at
    end
    placeholder_map_id = from(:maps).insert(name: 'gorge_placeholder')

    create_table :locations do
      primary_key :id

      foreign_key :map_id, :maps, null: false, on_update: :cascade, on_delete: :cascade

      String :name, null: false

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :update_at

      unique [:map_id, :name]
    end
    placeholder_location_id = from(:locations).insert(name: 'gorge_placeholder', map_id: placeholder_map_id)

    alter_table :rounds do
      add_foreign_key :map_id, :maps, null: false, default: placeholder_map_id, on_update: :cascade, on_delete: :restrict
      set_column_default :map_id, nil

      add_foreign_key :alien_starting_location_id,  :locations, null: false, default: placeholder_location_id, on_update: :cascade, on_delete: :restrict
      set_column_default :alien_starting_location_id, nil

      add_foreign_key :marine_starting_location_id, :locations, null: false, default: placeholder_location_id, on_update: :cascade, on_delete: :restrict
      set_column_default :marine_starting_location_id, nil
    end
  end

  down do
    alter_table :rounds do
      drop_foreign_key :map_id
      drop_foreign_key :alien_starting_location_id
      drop_foreign_key :marine_starting_location_id
    end

    drop_table :locations

    drop_table :maps

    alter_table :rounds do
      drop_column :length
    end
  end
end
