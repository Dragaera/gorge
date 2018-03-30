# coding: utf-8

module Gorge
  module Jobs
    # Remove downloaded data files exceeding a certain age.
    class RemoveDownloadedDataFiles
      extend Resque::Plugins::JobStats

      @queue = :remove_downloaded_data_files
      @durations_recorded = ::Gorge::Config::Resque::DURATIONS_RECORDED

      @logger = Gorge.logger(program: 'remove_downloaded_data_files')

      def self.perform
        # TODO: Belongs into method of `DataSourceUpdate`, also easier to unit-test that way.
        retention_period = Time.now - Config::DataImport::DATA_FILE_RETENTION_TIME
        @logger.info("Removing data files older than #{ retention_period }.")

        DataSourceUpdate.
          where(state: ['success', 'failed', 'downloading_failed', 'processing_failed']).
          exclude(file_path: nil).
          exclude(file_path: '<purged>'). # Can't be `file_path`: [nil, '<purged>']
          where { created_at < retention_period }.
          each do |update|
            if File.exist? update.file_path
              @logger.info("Deleting #{ update.file_path }")
              File.delete update.file_path
            else
              @logger.info("Unable to delete #{ update.file_path }, already gone.")
            end

            update.update(file_path: '<purged>')
        end
      end
    end
  end
end
