module Gorge
  module Importer
    RSpec.describe PlayerImporter do
      let(:server) { Gorge::Server.create(name: 'foo') }
      subject { PlayerImporter.new(server: server, source_db: ns2plus_database) }

      describe 'importing from a database' do
        it 'should import all players' do
          expect { subject.import }.to change { Player.count }.to 5
        end

        it 'should handle Steam IDs' do
          subject.import
          expect(Player.select_map(:steam_id)).to match_array [100, 101, 102, 103, 104]
        end
      end
    end
  end
end
