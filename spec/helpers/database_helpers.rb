module Gorge
  module Helpers
    module DatabaseHelpers
      def ns2plus_database
        db = Sequel.sqlite

        db.create_table 'PlayerRoundStats' do
          Integer :roundId
          Integer :steamId
          Integer :teamNumber

          Float :timePlayed
          Float :timeBuilding
          Float :commanderTime

          Integer :kills
          Integer :assists
          Integer :deaths
          Integer :killstreak

          Integer :hits
          Integer :onosHits
          Integer :misses

          Float :playerDamage
          Float :structureDamage

          Integer :score

          primary_key [:roundId, :steamId, :teamNumber]
        end

        db.create_table 'PlayerClassStats' do
          Integer :roundId
          Integer :steamId
          String  :class
          Float   :classTime
        end

        db.create_table 'RoundInfo' do
          primary_key :roundId
          String      :roundDate
          Integer     :roundLength
          Integer     :maxPlayers1
          Integer     :maxPlayers2
          Integer     :tournamentMode
          Integer     :winningTeam
          String      :mapName
          String      :locationNames
          # Yes, these two are strings, even though they are indices.
          String      :startingLocation1
          String      :startingLocation2
        end

        populate_rounds(db)
        populate_player_rounds(db)
        populate_player_class_stats(db)

        db
      end

      private
      def populate_rounds(db)
        foo_locations     = ['foo_1', 'foo_2', 'foo_3'].to_json
        bar_locations     = ['bar_1', 'bar_2', 'bar_3'].to_json
        bar_locations_new = ['baz_1', 'baz_2', 'baz_3'].to_json
        broken_locations  = ['broken_1', 'broken_2', 'broken_3'].to_json
        broken2_locations = [].to_json
        db[:RoundInfo].import(
          [
            :roundId,
            :roundDate,
            :roundLength,
            :maxPlayers1,
            :maxPlayers2,
            :tournamentMode,
            :winningTeam,
            :mapName,
            :locationNames,
            :startingLocation1,
            :startingLocation2
          ],
          [
            [1, '2017-01-01 01:00:00', 65,   12, 12, 0, 1, 'ns2_foo',   foo_locations, '1', '3'],
            [2, '2017-01-01 02:00:00', 2000, 10, 12, 0, 2, 'ns2_foo',   foo_locations, '1', '3'],
            [3, '2017-01-01 03:00:00', 1750, 10, 11, 0, 1, 'ns2_bar_2', bar_locations, '2', '3'],
            [4, '2017-01-01 04:00:00', 1232, 12, 12, 0, 0, 'ns2_bar_2', bar_locations, '2', '3'],
            [5, '2017-01-01 05:00:00', 900,  12, 12, 1, 1, 'ns2_bar_2', bar_locations_new, '2', '3'],
            [6, '2017-01-01 06:00:00', 1000, 12, 12, 1, 1, 'ns2_broken', broken_locations, nil, nil],
            [7, '2017-01-01 07:00:00', 1000, 12, 12, 1, 1, 'ns2_broken2', broken2_locations, '1', '2'],
          ]
        )
      end

      def populate_player_rounds(db)
        db[:PlayerRoundStats].import(
          [
            :roundId,
            :steamId,
            :teamNumber,

            :timePlayed,
            :timeBuilding,
            :commanderTime,

            :kills,
            :assists,
            :deaths,

            :killstreak,
            :hits,
            :onosHits,
            :misses,
            :playerDamage,
            :structuredamage,

            :score
          ],
          [
            [1, 100, 1, 3600, 60, 2700, 10, 3, 1, 5, 1_000, 200,  3_500, 3_000,     0, 125],
            [1, 101, 1, 3600, 60,  900,  3, 6, 7, 2, 2_500,  10, 10_000, 7_500,     0,  75],
            [1, 102, 2, 3600, 60, 3600,  7, 1, 4, 1,   750, 500,  4_000,   500, 1_700,  72],
            [1, 103, 2, 1800, 60,    0,  1, 3, 9, 1, 1_250, 250,  2_500, 3_000,   500,  25],

            [2, 104, 1, 3600, 60, 2700, 10, 3, 1, 5, 1_000, 200,  3_500, 3_000,     0, 125],
            [2, 101, 1, 3600, 60,  900,  3, 6, 7, 2, 2_500,  10, 10_000, 7_500,     0,  75],
            [2, 102, 2, 3600, 60, 3600,  7, 1, 4, 1,   750, 500,  4_000,   500, 1_700,  72],
            [2, 103, 2, 1800, 60,    0,  1, 3, 9, 1, 1_250, 250,  2_500, 3_000,   500,  25],
          ]
        )
      end

      def populate_player_class_stats(db)
        db[:PlayerClassStats].import(
          [
            :roundId,
            :steamId,
            :class,
            :classTime,
          ],
          [
            [1, 100, 'Rifle', 1000],
            [1, 100, 'Shotgun', 500],
            [1, 100, 'Gorge', 200],
            [1, 100, 'Onos', 3000],
            [2, 100, 'Rifle',50]
          ]
        )
      end
    end
  end
end
