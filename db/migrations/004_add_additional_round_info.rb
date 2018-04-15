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

    alter_table :rounds do
      add_foreign_key :map_id, :maps, null: false, default: placeholder_map_id
      set_column_default :map_id, nil
    end
  end

  down do
    alter_table :rounds do
      drop_foreign_key :map_id
    end

    drop_table :maps

    alter_table :rounds do
      drop_column :length
    end
  end
end
