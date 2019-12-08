# coding: utf-8

module Gorge
  module Web
    RSpec.describe 'The players API' do
      describe "querying for a player's statistics" do
        it "returns a JSON data structure with the player's statistics" do
          player = create(:player, steam_id: 1)

          cls = create(:player_statistics_class, name: 'n_1', sample_size: 1)
          alien_stats = create(
            :player_statistics,
            player_statistics_class: cls,
            player: player,
            team: Gorge::Team.aliens
          )
          PlayerCurrentStatistics.create(
            player: player,
            team: Gorge::Team.aliens,
            player_statistics_class: cls,
            player_statistics: alien_stats
          )
          marine_stats = create(
            :player_statistics,
            player_statistics_class: cls,
            player: player,
            team: Gorge::Team.marines,
            kills: 20,
            deaths: 5,
            kdr: 4,
            hits: 1000,
            misses: 5000,
            onos_hits: 500,
            accuracy: 0.2,
            accuracy_no_onos: 0.1,
          )
          PlayerCurrentStatistics.create(
            player: player,
            team: Gorge::Team.marines,
            player_statistics_class: cls,
            player_statistics: marine_stats
          )

          get '/players/1/statistics', { statistics_classes: cls.name }
          expect(last_response).to be_ok

          data = JSON.parse(last_response.body)
          expect(data).to eq (
            {
              '_' => {
                'steam_id' => 1,
              },
              'n_1' => {
                '_' => {
                  'sample_size' => 1,
                },
                'accuracy' => {
                  'alien' => 0.1,
                  'marine' => {
                    'total' => 0.2,
                    'no_onos' => 0.1,
                  },
                },
                'kdr' => {
                  'alien' => 1.0,
                  'marine' => 4.0,
                },
              },
            }
          )
        end

        it 'returns an HTTP 400 if the supplied Steam ID is non-numeric' do
          cls = create(:player_statistics_class)
          get '/players/test/statistics', { statistics_classes: cls.name }
          expect(last_response.status).to eq 400
        end

        it 'returns an HTTP 404 if querying for a non-existant player' do
          cls = create(:player_statistics_class)
          get '/players/123/statistics', { statistics_classes: cls.name }
          expect(last_response.status).to eq 404
        end
      end
    end
  end
end
