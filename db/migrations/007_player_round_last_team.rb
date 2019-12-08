Sequel.migration do
  up do
    alter_table :player_rounds do
      add_foreign_key :last_team_id, :teams, on_update: :cascade, on_delete: :restrict
    end

    from(:player_rounds).update(last_team_id: :team_id)
  end

  down do
    alter_table :player_rounds do
      drop_foreign_key :last_team_id
    end
  end
end
