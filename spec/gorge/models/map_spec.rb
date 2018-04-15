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
  end
end
