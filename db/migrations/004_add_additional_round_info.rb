Sequel.migration do
  up do
    alter_table :rounds do
      add_column :length, Integer
    end
  end

  down do
    alter_table :rounds do
      drop_column :length
    end
  end
end
