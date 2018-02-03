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

        db.create_table 'RoundInfo' do
          primary_key :roundId
          String      :roundDate
          Integer     :maxPlayers1
          Integer     :maxPlayers2
          Integer     :tournamentMode
          Integer     :winningTeam
        end

        populate_rounds(db)

        db
      end

      private
      def populate_rounds(db)
        db[:RoundInfo].import(
          [
            :roundId,
            :roundDate,
            :maxPlayers1,
            :maxPlayers2,
            :tournamentMode,
            :winningTeam
          ],
          [
            [1, '2017-01-01 01:00:00', 12, 12, 0, 1],
            [2, '2017-01-01 02:00:00', 10, 12, 0, 2],
            [3, '2017-01-01 03:00:00', 10, 11, 0, 1],
            [4, '2017-01-01 04:00:00', 12, 12, 0, 0],
            [5, '2017-01-01 05:00:00', 12, 12, 1, 1],
          ]
        )
      end
    end
  end
end
