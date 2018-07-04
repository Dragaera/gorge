module Gorge
  FactoryBot.define do
    to_create(&:save)

    trait :disabled do
      enabled false
    end

    factory :server, class: Gorge::Server do
      name 'FactoryBot Server'
    end

    factory :player, class: Gorge::Player do
      sequence(:steam_id)
    end

    factory :round, class: Gorge::Round do
      server

      map_id 1
      alien_starting_location_id 1
      marine_starting_location_id 1

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

    factory :data_source, class: Gorge::DataSource do
      name 'data_source'
      url 'http://localhost/foo'
      server
      update_frequency { Gorge::UpdateFrequency.first(auto_update: true) }
    end

    factory :api_user, class: Gorge::APIUser do
      user { SecureRandom.uuid }
      token { SecureRandom.hex(32) }
      enabled true
    end

    factory :map, class: Gorge::Map do
      sequence(:name) { |i| "ns2_map#{ i }" }
    end

    factory :location, class: Gorge::Location do
      map

      sequence(:name) { |i| "ns2_map#{ i }" }
    end
  end
end
