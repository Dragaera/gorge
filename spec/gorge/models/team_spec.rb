module Gorge
  RSpec.describe Team do
    describe '::draw' do
      it 'returns the team with ID 0' do
        expect(Team.draw.id).to eq 0
      end
    end

    describe '::marines' do
      it 'returns the team with ID 1' do
        expect(Team.marines.id).to eq 1
      end
    end

    describe '::aliens' do
      it 'returns the team with ID 2' do
        expect(Team.aliens.id).to eq 2
      end
    end
  end
end
