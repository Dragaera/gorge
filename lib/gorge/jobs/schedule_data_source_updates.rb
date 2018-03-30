# coding: utf-8

module Gorge
  module Jobs
    # Schedule updates of data sources which are in need of one.
    class ScheduleDataSourceUpdates
      extend Resque::Plugins::JobStats

      @queue = :schedule_data_source_updates
      @durations_recorded = ::Gorge::Config::Resque::DURATIONS_RECORDED

      @logger = Gorge.logger(program: 'schedule_data_source_updates')

      def self.perform
        DataSource.stale.each do |ds|
          @logger.info({ msg: 'Scheduling update for stale data source.', data_source: ds.identifier })
          ds.async_process
        end
      end
    end
  end
end
