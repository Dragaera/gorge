module Gorge
  FactoryBot.define do
    to_create(&:save)

    factory :server, class: Gorge::Server do
      name 'FactoryBot Server'
    end

    factory :player, class: Gorge::Player do
      sequence(:steam_id)
    end

    factory :round, class: Gorge::Round do
      server

      sequence(:round_id)
      timestamp Time.new(2017, 1, 1)
      max_players_marines 8
      max_players_aliens 8
      tournament_mode false
      winning_team_id 1
    end

    factory :player_round, class: Gorge::PlayerRound do
      player
      round

      team Gorge::Team.marines
      time_played 600
      time_building 60
      time_commander 30
      kills 10
      assists 5
      deaths 20
      killstreak 3
      hits 5_000
      onos_hits 1_000
      misses 10_000
      player_damage 12_000
      structure_damage 3_000
      score 100
    end
  end
end
