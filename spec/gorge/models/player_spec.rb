module Gorge
  RSpec.describe Player do
    let(:server) { create(:server) }
    subject { create(:player) }

    before(:each) do
      [
        [10, 5, 1000, 0,   500],
        [7,  7, 750,  250, 500],
        [11, 7, 200,  190, 300]
      ].each do |kills, deaths, hits, onos_hits, misses|
        round = create(:round, server: server)
        create(
          :player_round,
          player: subject,
          round: round,
          kills: kills,
          deaths: deaths,
          hits: hits,
          onos_hits: onos_hits,
          misses: misses,
          team: Team.marines
        )
      end

      [
        [4, 5, 570,  0, 1200],
        [8, 7, 2300, 0, 450],
        [5, 7, 1200, 0, 800]
      ].each do |kills, deaths, hits, onos_hits, misses|
        round = create(:round, server: server)
        create(
          :player_round,
          player: subject,
          round: round,
          kills: kills,
          deaths: deaths,
          hits: hits,
          onos_hits: onos_hits,
          misses: misses,
          team: Team.aliens
        )
      end
    end

    describe '#kdr' do
      it "returns the player's overall KDR" do
        expect(subject.kdr).to be_within(0.01).of(1.18)
      end
    end

    describe '#alien_kdr' do
      it "returns the player's alien KDR" do
        expect(subject.alien_kdr).to be_within(0.01).of(0.89)
      end
    end

    describe '#marine_kdr' do
      it "returns the player's marine KDR" do
        expect(subject.marine_kdr).to be_within(0.01).of(1.47)
      end
    end

    describe '#accuracy' do
      it "returns the player's overall accuracy" do
        expect(subject.accuracy).to be_within(0.01).of(0.623)
      end
    end

    describe '#alien_accuracy' do
      it "returns the player's alien accuracy" do
        expect(subject.alien_accuracy).to be_within(0.01).of(0.624)
      end
    end

    describe '#marine_accuracy' do
      it "returns the player's marine accuracy including onos hits by default" do
        expect(subject.marine_accuracy).to be_within(0.01).of(0.6)
      end

      it "returns the player's marine accuracy excluding onos hits if specified" do
        expect(subject.marine_accuracy(include_onos: false)).to be_within(0.01).of(0.537)
      end
    end

    describe '#statistics' do
      it 'returns a hash containing various statistics' do
        expected = {
          steam_id: subject.steam_id,
          kdr: {
            total:  subject.kdr,
            alien:  subject.alien_kdr,
            marine: subject.marine_kdr,
          },
          accuracy: {
            total: subject.accuracy,
            alien: subject.alien_accuracy,
            marine: {
              total:   subject.marine_accuracy,
              no_onos: subject.marine_accuracy(include_onos: false),
            }
          }
        }

        expect(subject.statistics).to eq (expected)
      end
    end
  end
end
