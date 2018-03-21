# coding: utf-8

module Gorge
  module Web
    RSpec.describe 'The players API' do
      describe "querying for a player's statistics" do
        it "returns a JSON data structure with the player's statistics" do
          player = create(:player, steam_id: 1)
          create(
            :player_round,
            player: player,
            kills: 10,
            deaths: 5,
            hits: 100,
            onos_hits: 50,
            misses: 900,
            team: Team.marines
          )

          create(
            :player_round,
            player: player,
            kills: 20,
            deaths: 5,
            hits: 500,
            onos_hits: 0,
            misses: 500,
            team: Team.aliens
          )


          get '/players/1/statistics'
          expect(last_response).to be_ok

          data = JSON.parse(last_response.body)
          expect(data).to eq (
            {
              'steam_id' => player.steam_id,
              'accuracy' => {
                'total' => player.accuracy,
                'alien' => player.alien_accuracy,
                'marine' => {
                  'total' => player.marine_accuracy,
                  'no_onos' => player.marine_accuracy(include_onos: false)
                }
              },
              'kdr' => {
                'total' => player.kdr,
                'alien' => player.alien_kdr,
                'marine' => player.marine_kdr
              }
            }
          )
        end

        it 'returns an HTTP 400 if the supplied Steam ID is non-numeric' do
          get '/players/test/statistics'
          expect(last_response.status).to eq 400
        end

        it 'returns an HTTP 404 if querying for a non-existant player' do
          get '/players/123/statistics'
          expect(last_response.status).to eq 404
        end
      end
    end
  end
end
