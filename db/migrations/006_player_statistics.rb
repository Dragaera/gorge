Sequel.migration do
  up do
    create_table :player_statistics_classes do
      primary_key :id

      String :name,        null: false, unique: true
      Fixnum :sample_size, null: false, unique: true

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :update_at
    end

    create_table :player_statistics do
      primary_key :id

      foreign_key :player_statistics_class_id, :player_statistics_classes, null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :player_id,                  :players,                   null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :team_id,                    :teams,                     null: false, on_update: :cascade, on_delete: :cascade

      Fixnum   :kills,       null: false
      Fixnum   :deaths,      null: false
      Float    :kdr,         null: false
      Fixnum   :hits,        null: false
      Fixnum   :onos_hits
      Fixnum   :misses,      null: false
      Float    :accuracy,    null: false
      Float    :accuracy_no_onos
      Fixnum   :round_count, null: false
      DateTime :from,        null: false
      DateTime :to,          null: false

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :update_at
    end

    alter_table :players do
      add_foreign_key :current_aliens_statistics_id,  :player_statistics, on_update: :cascade, on_delete: :cascade
      add_foreign_key :current_marines_statistics_id, :player_statistics, on_update: :cascade, on_delete: :cascade
    end
  end

  down do
    alter_table :players do
      drop_foreign_key :current_aliens_statistics_id
      drop_foreign_key :current_marines_statistics_id
    end

    drop_table :player_statistics

    drop_table :player_statistics_classes
  end
end
