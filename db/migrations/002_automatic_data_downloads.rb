Sequel.migration do
  up do
    create_table :update_frequencies do
      primary_key :id

      String  :name,        null: false, unique: true
      Integer :interval,    null: false
      Bool    :auto_update, null: false, default: true
    end
    [['none', 0, false], ['daily', 24 * 60 * 60, true], ['weekly', 7 * 24 * 60 * 60, true]].each do |ary|
      from(:update_frequencies).insert(name: ary[0], interval: ary[1], auto_update: ary[2])
    end

    create_table :data_sources do
      primary_key :id

      foreign_key :server_id,           :servers,             null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :update_frequency_id, :update_frequencies,  null: false, on_update: :cascade, on_delete: :restrict

      String   :name,    null: false
      String   :url,     null: false
      DateTime :last_update_at
      DateTime :next_update_at
      DateTime :update_scheduled_at
      Bool     :enabled, null: false, default: true

      unique [:server_id, :name]
    end

    create_enum(:data_source_update_state, ['scheduled', 'downloading', 'downloading_failed', 'processing', 'processing_failed', 'success', 'failed'])
    create_table :data_source_updates do
      primary_key :id

      foreign_key :data_source_id, null: false, on_update: :cascade, on_delete: :cascade

      data_source_update_state :state
      String                   :url
      String                   :file_path
      String                   :error_message
      Integer                  :download_time
      Integer                  :processing_time
      DateTime                 :timestamp
    end

    alter_table :data_sources do
      add_foreign_key :current_update_id, :data_source_updates, on_update: :cascade, on_delete: :restrict
    end
  end

  down do
    alter_table :data_sources do
      drop_foreign_key :current_update_id
    end
    drop_table :data_source_updates
    drop_enum(:data_source_update_state)
    drop_table :data_sources
    drop_table :update_frequencies
  end
end
