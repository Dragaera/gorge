module Gorge
  module Importer
    RSpec.describe PlayerRoundImporter do
      let(:server) { create(:server) }
      subject { PlayerRoundImporter.new(server: server, source_db: ns2plus_database) }

      describe 'importing from a database' do
        before(:each) do
          [100, 101, 102, 103, 104].each do |steam_id|
            create(:player, steam_id: steam_id)
          end

          [1, 2].each do |round_id|
            create(:round, round_id: round_id, server: server)
          end
        end

        it 'should import all player rounds' do
          expect { subject.import }.to change { PlayerRound.count }.to 8
        end

        it 'should handle team number' do
          subject.import

          player1 = Player.first(steam_id: 101)
          player2 = Player.first(steam_id: 102)
          round = Round.first(round_id: 1, server: server)
          expect(PlayerRound.first(player: player1, round: round).team).to eq Team.marines
          expect(PlayerRound.first(player: player2, round: round).team).to eq Team.aliens
        end

        it 'should handle all other attributes' do
          subject.import

          player = Player.first(steam_id: 101)
          round = Round.first(round_id: 1, server: server)

          expect(
            PlayerRound.first(
              player: player,
              round:  round,
            )
          ).to eq(
            build(:player_round,
              player: player,
              round: round,
              team: Team.marines,
              time_played: 3600,
              time_building: 60,
              time_commander: 900,
              kills: 3,
              assists: 6,
              deaths: 7,
              killstreak: 2,
              hits: 2_500,
              onos_hits: 10,
              misses: 10_000,
              player_damage: 7_500,
              structure_damage: 0,
              score: 75
            )
          )
        end
      end
    end
  end
end
