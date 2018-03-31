Sequel.migration do
  up do
    create_table :api_users do
      primary_key :id

      UUID   :user,  null: false, unique: true
      String :token, null: false, size: 64
      Time   :last_used_at
      String :description

      Bool :enabled, null: false, default: true

      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Time :update_at
    end
  end

  down do
    drop_table :api_users
  end
end
