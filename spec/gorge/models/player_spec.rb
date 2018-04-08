module Gorge
  RSpec.describe Player do
    let(:server) { create(:server) }
    subject { create(:player) }

    # No deaths, no hits, no misses...
    let(:odd_player) { create(:player) }
    before(:each) do
      round = create(:round, server: server)
      create(
        :player_round,
        player: odd_player,
        round: round,
        kills: 10,
        deaths: 0,
        hits: 0,
        onos_hits: 50,
        misses: 0,
        team: Team.marines
      )
      create(
        :player_round,
        player: odd_player,
        round: round,
        kills: 5,
        deaths: 0,
        hits: 0,
        onos_hits: 0,
        misses: 0,
        team: Team.aliens
      )
    end

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

      it 'handles the player never having died' do
        expect(odd_player.kdr).to eq 15
      end
    end

    describe '#alien_kdr' do
      it "returns the player's alien KDR" do
        expect(subject.alien_kdr).to be_within(0.01).of(0.89)
      end

      it 'handles the player never having died' do
        expect(odd_player.alien_kdr).to eq 5
      end
    end

    describe '#marine_kdr' do
      it "returns the player's marine KDR" do
        expect(subject.marine_kdr).to be_within(0.01).of(1.47)
      end

      it 'handles the player never having died' do
        expect(odd_player.marine_kdr).to eq 10
      end
    end

    describe '#accuracy' do
      it "returns the player's overall accuracy" do
        expect(subject.accuracy).to be_within(0.01).of(0.623)
      end

      it 'handles the player having 0 hits and misses' do
        expect(odd_player.accuracy).to eq 0
      end
    end

    describe '#alien_accuracy' do
      it "returns the player's alien accuracy" do
        expect(subject.alien_accuracy).to be_within(0.01).of(0.624)
      end

      it 'handles the player having 0 hits and misses' do
        expect(odd_player.alien_accuracy).to eq 0
      end
    end

    describe '#marine_accuracy' do
      it "returns the player's marine accuracy including onos hits by default" do
        expect(subject.marine_accuracy).to be_within(0.01).of(0.6)
      end

      it "returns the player's marine accuracy excluding onos hits if specified" do
        expect(subject.marine_accuracy(include_onos: false)).to be_within(0.01).of(0.537)
      end

      it 'handles the player having 0 hits and misses' do
        expect(odd_player.marine_accuracy).to eq 0
      end

      it 'handles the player having exclusively onos hits' do
        onos_hitter = create(:player)
        create(
          :player_round,
          player: onos_hitter,
          round: create(:round, server: server),
          hits: 10,
          misses: 0,
          onos_hits: 10,
        )

        expect(onos_hitter.marine_accuracy(include_onos: false)). to eq 0
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

      # Can't rely on tests for #kdr etc, as #statistics has duplicated
      # queries, to be able to do it in as few queries as possible.
      it 'handles the player having odd data' do
        expected = {
          steam_id: odd_player.steam_id,
          kdr: {
            total:  odd_player.kdr,
            alien:  odd_player.alien_kdr,
            marine: odd_player.marine_kdr,
          },
          accuracy: {
            total: odd_player.accuracy,
            alien: odd_player.alien_accuracy,
            marine: {
              total:   odd_player.marine_accuracy,
              no_onos: odd_player.marine_accuracy(include_onos: false),
            }
          }
        }

        expect(odd_player.statistics).to eq (expected)
      end
    end
  end
end
