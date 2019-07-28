module Gorge
  RSpec.describe Map do
    describe '::get_or_create' do
      it 'returns the map if it exists' do
        expected = create(:map)

        expect(Map.get_or_create(expected.name).id).to eq expected.id
      end

      it 'creates the map if it does not exist' do
        expect(Map.get_or_create('test').name).to eq 'test'
      end
    end

    describe '::generate_cache' do
      let(:map_1) { create(:map) }
      let(:map_2) { create(:map) }

      it 'creates a cache for all existing maps' do
        expected = {
          map_1.name => map_1,
          map_1.name => map_1,
        }

        expect(Map.generate_cache).to eq expected
      end
    end
  end
end
