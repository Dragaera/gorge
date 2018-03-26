module Gorge
  RSpec.describe DataSource do
    let(:server) { create(:server, name: 'Foobar emporium') }
    let(:data_source) { create(:data_source, name: 'HTTP Download', server: server, url: 'http://127.0.0.1/ns2plus.sqlite3') }

    describe '#process' do
      # TODO
      context 'if the download succeeds' do
      end

      context 'if the download fails' do
        context 'due to a non-success HTTP status code' do
          it 'sets the state accordingly' do
            response = Typhoeus::Response.new(code: 404, body: 'Not found')
            Typhoeus.stub('http://127.0.0.1/ns2plus.sqlite3').and_return(response)

            data_source.process
            expect(data_source.current_update.state).to eq('downloading_failed')
          end
        end
      end
    end

    describe '#identifier' do
      it 'returns a string-based identifier' do

        expect(data_source.identifier).to eq 'foobar_emporium_http_download'
      end
    end
  end
end
