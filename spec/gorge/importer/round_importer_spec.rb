module Gorge
  module Importer
    RSpec.describe RoundImporter do
      let(:server) { create(:server) }
      subject { RoundImporter.new(server: server, source_db: ns2plus_database) }

      describe 'importing from a database' do
        it 'should import all rounds' do
          expect { subject.import }.to change { Round.count }.to 5
        end

        it 'should handle tournament mode' do
          subject.import
          expect(Round.first(round_id: 1).tournament_mode).to eq false
          expect(Round.first(round_id: 5).tournament_mode).to eq true
        end

        it 'should handle winning teams' do
          subject.import
          expect(Round.first(round_id: 1).winning_team).to eq Team.marines
          expect(Round.first(round_id: 2).winning_team).to eq Team.aliens
          expect(Round.first(round_id: 4).winning_team).to eq Team.draw
        end

        it 'should handle round timestamps' do
          subject.import
          expect(Round.first(round_id: 1).timestamp).to eq Time.new(2017, 1, 1, 1, 0, 0)
          expect(Round.first(round_id: 5).timestamp).to eq Time.new(2017, 1, 1, 5, 0, 0)
        end

        it 'should handle maximum player count' do
          subject.import
          round = Round.first(round_id: 3)
          expect(round.max_players_marines).to eq 10
          expect(round.max_players_aliens).to eq 11
        end

        it 'should attach it to the appropriate server' do
          subject.import
          Round.each do |round|
            expect(round.server).to eq server
          end
        end
      end
    end
  end
end
