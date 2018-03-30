# coding: utf-8

module Gorge
  module Jobs
    # Reset the 'update pending' status of data sources after a certain grace period.
    #
    # This serves to prevent unhandled exceptions from causing a data source to
    # not be updated anymore at all.
    class ResetPendingUpdates
      extend Resque::Plugins::JobStats

      @queue = :reset_pending_updates
      @durations_recorded = ::Gorge::Config::Resque::DURATIONS_RECORDED

      @logger = Gorge.logger(program: 'reset_pending_updates')

      def self.perform
        grace_period = Time.now - Config::DataImport::UPDATE_GRACE_PERIOD
        @logger.info("Resetting pending updates older than #{ grace_period }.")
        DataSource.
          exclude(update_scheduled_at: nil).
          where { update_scheduled_at < grace_period }.
          each do |ds|
          @logger.info({ msg: 'Resetting pending update.', data_source: ds.identifier })
          ds.update(update_scheduled_at: nil)
        end
      end
    end
  end
end
