module Gorge
  RSpec.describe Location do
    describe '::get_or_create' do
      let(:map) { create(:map) }

      it 'returns the location if it exists' do
        expected = create(:location, map: map)

        expect(Location.get_or_create(expected.name, map: map).id).to eq expected.id
      end

      it 'creates the location if it does not exist' do
        expect { Location.get_or_create('test', map: map) }.to change { Location.count }.by 1
      end
    end
  end
end
