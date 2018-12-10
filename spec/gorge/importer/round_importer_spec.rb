module Gorge
  module Importer
    RSpec.describe RoundImporter do
      let(:server) { create(:server) }
      subject { RoundImporter.new(server: server, source_db: ns2plus_database) }

      describe 'importing from a database' do
        it 'should import all rounds' do
          expect { subject.import }.to change { Round.count }.to 7
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

        it 'should handle round length' do
          subject.import
          expect(Round.first(round_id: 1).length).to eq 65
          expect(Round.first(round_id: 5).length).to eq 900
        end

        it 'should attach it to the appropriate server' do
          subject.import
          Round.each do |round|
            expect(round.server).to eq server
          end
        end

        it 'should create not-yet-existing maps' do
          expect { subject.import }.to change { Map.count }.by(4)
        end

        it 'should handle maps' do
          subject.import

          [1, 2].each do |i|
            expect(Round.first(round_id: i).map.name).to eq 'ns2_foo'
          end

          [3, 4, 5].each do |i|
            expect(Round.first(round_id: i).map.name).to eq 'ns2_bar_2'
          end
        end

        it 'should create not-yet-existing locations' do
          # 12 locations defined in DB helper, plus one automatically created
          # fallback location per map.
          expect { subject.import }.to change { Location.count }.by(16)
        end

        it 'should handle locations' do
          subject.import

          round_1 = Round.first(round_id: 1)
          expect(round_1.alien_starting_location.name).to eq 'foo_3'
          expect(round_1.marine_starting_location.name).to eq 'foo_1'
        end

        it 'should handle maps with changing locations' do
          subject.import

          round_5 = Round.first(round_id: 5)
          expect(round_5.alien_starting_location.name).to eq 'baz_3'
          expect(round_5.marine_starting_location.name).to eq 'baz_2'
        end

        it 'should handle maps with no locations' do
          subject.import

          round_6 = Round.first(round_id: 6)
          expect(round_6.marine_starting_location.name).to eq 'UNDEFINED'
        end

        it 'should handle maps with undefined starting locations' do
          subject.import

          round_7 = Round.first(round_id: 7)
          expect(round_7.marine_starting_location.name).to eq 'UNDEFINED'
        end
      end
    end
  end
end
