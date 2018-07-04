module Gorge
  module Importer
    RSpec.describe PlayerClassImporter do
      let(:server) { create(:server) }
      let!(:player) { create(:player, steam_id: 100) }
      subject { PlayerClassImporter.new(server: server, source_db: ns2plus_database) }

      describe 'importing from a database' do
        before(:each) do
          [1, 2].each do |round_id|
            create(:round, round_id: round_id, server: server)
          end
        end

        it 'should import all player class stats' do
          expect { subject.import }.to change { PlayerClassStatistic.count }.to 5
        end

        it 'should handle class time' do
          subject.import

          round1 = Round.first(round_id: 1, server: server)
          round2 = Round.first(round_id: 2, server: server)

          class_rifle = PlayerClass.first(name: 'Rifle')
          class_onos  = PlayerClass.first(name: 'Onos')

          expect(PlayerClassStatistic.first(player: player, round: round1, player_class: class_rifle).time_played).to eq 1000
        end
      end
    end
  end
end
