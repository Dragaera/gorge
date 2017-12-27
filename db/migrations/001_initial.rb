Sequel.migration do
  up do
    create_table :teams do
      primary_key :id

      String :name, null: false, unique: true
    end
    [[0, 'Draw'], [1, 'Marines'], [2, 'Aliens']].each do |ary|
      from(:teams).insert(id: ary[0], name: ary[1])
    end

    create_table :servers do
      primary_key :id

      String :name, null: false
    end

    create_table :rounds do
      primary_key :id

      foreign_key :server_id, :servers, null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :winning_team_id, :teams, null: false, on_update: :cascade, on_delete: :restrict

      Integer  :round_id,            null: false
      DateTime :timestamp,           null: false
      Integer  :max_players_marines, null: false
      Integer  :max_players_aliens,  null: false
      Bool     :tournament_mode,     null: false

      index [:server_id, :round_id], unique: true
    end

    create_table :players do
      primary_key :id

      Integer :steam_id, null: false, unique: true
    end

    create_table :player_rounds do
      primary_key :id

      foreign_key :player_id, :players, null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :round_id,  :rounds,  null: false, on_update: :cascade, on_delete: :cascade
      foreign_key :team_id,   :teams,   null: false, on_update: :cascade, on_delete: :restrict

      Float :time_played,    null: false
      Float :time_building,  null: false
      Float :time_commander, null: false

      Integer :kills,       null: false
      Integer :assists,     null: false
      Integer :deaths,      null: false
      Integer :killstreak,  null: false

      Integer :hits,      null: false
      Integer :onos_hits, null: false
      Integer :misses,    null: false

      Float :player_damage,    null: false
      Float :structure_damage, null: false

      Integer :score, null: false

      index [:round_id, :player_id, :team_id], unique: true
    end
  end

  down do
    drop_table :player_rounds
    drop_table :players
    drop_table :rounds
    drop_table :servers
    drop_table :teams
  end
end
