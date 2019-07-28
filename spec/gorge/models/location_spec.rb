module Gorge
  RSpec.describe Location do
    let(:map_1) { create(:map) }
    let!(:location_1) { create(:location, map: map_1) }
    let!(:map_2) { create(:map) }
    let!(:location_2) { create(:location, map: map_2) }

    describe '::get_or_create' do
      it 'returns the location if it exists' do
        expected = create(:location, map: map_1)

        expect(Location.get_or_create(expected.name, map: map_1).id).to eq expected.id
      end

      it 'creates the location if it does not exist' do
        expect { Location.get_or_create('test', map: map_1) }.to change { Location.count }.by 1
      end
    end

    describe '::generate_cache' do

      it 'creates a cache for all existing maps / locations' do
        expected = {
          map_1.name => {
            location_1.name => location_1,
            fallback: Location.fallback(map: map_1),
          },
          map_2.name => {
            location_2.name => location_2,
            fallback: Location.fallback(map: map_2),
          }
        }

        expect(Location.generate_cache).to eq expected
      end
    end
  end
end
