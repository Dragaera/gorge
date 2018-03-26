module Gorge
  RSpec.describe DataSource do
    describe '#identifier' do
      it 'returns a string-based identifier' do
        server = create(:server, name: 'Foobar emporium')
        ds     = create(:data_source, name: 'HTTP Download', server: server)

        expect(ds.identifier).to eq 'foobar_emporium_http_download'
      end
    end
  end
end
