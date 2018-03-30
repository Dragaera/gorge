module Gorge
  RSpec.describe DataSource do
    let(:server) { create(:server, name: 'Foobar emporium') }
    let(:data_source) { create(:data_source, name: 'HTTP Download', server: server, url: 'http://127.0.0.1/ns2plus.sqlite3') }

    describe '::stale' do
      it 'returns data sources which need to have an update scheduled' do
        ds1 = create(:data_source, next_update_at: Time.new(2018, 1, 1, 11))
        ds2 = create(:data_source, next_update_at: Time.new(2018, 1, 1, 13))
        ds3 = create(:data_source, next_update_at: Time.new(2018, 1, 1, 15))

        Timecop.freeze(Time.new(2018, 1, 1, 14)) do
        puts Time.now
          expect(DataSource.stale).to match_array([ds1, ds2])
        end
      end

      it 'does not return data sources for which an updates is scheduled already' do
        ds = create(:data_source, update_scheduled_at: Time.now)
        expect(DataSource.stale).to_not include(ds)
      end

      it 'does not return disabled data sources' do
        ds = create(:data_source, enabled: false)
        expect(DataSource.stale).to_not include(ds)
      end

      it 'does not return data sources with non-auto-updating update frequencies' do
        ds = create(:data_source, update_frequency: UpdateFrequency.first(auto_update: false))
        expect(DataSource.stale).to_not include(ds)
      end
    end

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
