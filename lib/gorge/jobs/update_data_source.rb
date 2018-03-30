# coding: utf-8

module Gorge
  module Jobs
    # Schedule updates of data sources which are in need of one.
    class UpdateDataSource
      extend Resque::Plugins::JobStats

      @queue = :update_data_source
      @durations_recorded = ::Gorge::Config::Resque::DURATIONS_RECORDED

      @logger = Gorge.logger(program: 'update_data_source')

      def self.perform(data_source_id)
        ds = DataSource[data_source_id]
        unless ds
          @logger.error({ msg: 'Unknown data source', data_source_id: data_source_id })
          raise ArgumentError, "Unknown data source with id #{ data_source_id }"
        end

        ds.process
      end
    end
  end
end
