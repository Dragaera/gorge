# coding: utf-8

module Gorge
  class DataSource < Sequel::Model
    many_to_one :update_frequency
    many_to_one :server
    one_to_many :data_source_updates
    many_to_one :current_update, class: :'Gorge::DataSourceUpdate', key: :current_update_id

    def self.stale
      dataset.
        where(enabled: true, update_scheduled_at: nil).
        where { next_update_at < Time.now }.
        to_a.
        select { |ds| ds.update_frequency.auto_update }
    end

    def async_process
      update(
        update_scheduled_at: Time.now
      )

      Resque.enqueue(Jobs::UpdateDataSource, id)
    end

    def process
      @logger = Gorge.logger(program: 'gorge', module_: 'data_source_processing')
      @logger.add_attribute(:name, name)
      @logger.add_attribute(:server, server.name)

      @logger.debug({ msg: 'Starting data source processing' })

      update(
        current_update: create_data_source_update
      )

      if fetch_data && process_data
        @logger.debug({ msg: 'Processing finished' })
        next_update_ts = if next_update_at <= Time.now
                           # We'll set the next update based on when the current update should
                           # have started, to prevent it from slowly drifting forward due to the
                           # time it takes to download and process the data.
                           (next_update_at || Time.now) + update_frequency.interval
                         else
                           # Prevent pushing next_update_at further and further
                           # if `#process` was called too early, eg due to
                           # manual intervention.
                           next_update_at
                         end
        update(
          last_update_at:      Time.now,
          next_update_at:      next_update_ts,
          update_scheduled_at: nil,
          error_count: 0,
        )

        current_update.update(
          state: :success,
        )
      else
        update(
          update_scheduled_at: nil,
          error_count: error_count + 1
        )

        if error_count >= Gorge::Config::DataImport::ERROR_THRESHOLD
          @logger.warn({ msg: 'Disabling data source due to exceeding error count.' })
          update(enabled: false)
        end
      end
    end

    def identifier
      [
        server.name,
        name
      ].join('_').gsub(/\s/, '_').downcase
    end

    private
    def create_data_source_update
      add_data_source_update(
        DataSourceUpdate.new(
          state:     :scheduled,
          url:       url
        )
      )
    end

    def fetch_data
      @logger.add_attribute(:url, url)
      current_update.update(
        state: :downloading
      )

      @logger.debug({ msg: 'Downloading data file' })
      download_started_at = Time.now
      request = Typhoeus::Request.new(
        url,
        accept_encoding: 'gzip',
        connecttimeout: Config::DataImport::HTTP_CONNECT_TIMEOUT,
      )

      result = false
      buffer = output_file

      request.on_body do |chunk|
        buffer.write(chunk)
      end

      request.on_complete do |response|
        buffer.close

        result = if response.success?
                   download_success(Time.now - download_started_at, buffer.path)

                   true
                 elsif response.timed_out?
                   download_error 'Timeout while connecting'
                 elsif response.code == 0
                   # Non-HTTP error
                   download_error "Error while downloading: #{ response.return_message }"
                 else
                   # HTTP error
                   download_error "Non-success status code received: #{ response.code }"
                 end
        @logger.remove_attribute :url
      end

      request.run

      return result

    rescue Exception => e
      buffer.close if buffer
      download_exception(e)

      false
    end

    def process_data
      @logger.add_attribute(:file_path, current_update.file_path)

      current_update.update(
        state: :processing
      )

      processing_started_at = Time.now
      importer = Importer::Importer.new(current_update.file_path, server: server)
      importer.import
      current_update.update(
        processing_time: Time.now - processing_started_at
      )

      @logger.remove_attribute :file_path

      true
    rescue Exception => e
      processing_exception(e)

      false
    end

    def download_success(time_taken, file_path)
      @logger.debug({ msg: 'Sucessfully downloaded', download_time: time_taken })
      current_update.update(
        download_time: time_taken,
        file_path: file_path
      )

      true
    end

    def download_error(msg)
      @logger.error({ msg: msg, success: false })
      current_update.update(
        state:         :downloading_failed,
        error_message: msg,
      )

      false
    end

    def download_exception(e)
      msg = "Unhandled #{ e.class } while downloading: #{ e.message }"
      @logger.error({ msg: msg })
      current_update.update(
        state: :failed,
        error_message: msg
      )

      false
    end

    def processing_exception(e)
      msg = "Unhandled #{ e.class } while processing: #{ e.message }"
      current_update.update(
        state: :processing_failed,
        error_message: msg
      )

      false
    end

    def output_file
      ts = Time.now.strftime('%Y%m%d_%H%M%S')
      file_name = "#{ identifier }_#{ ts }.sqlite3"

      path = File.join(Config::DataImport::STORAGE_PATH, file_name)
      File.open(path, 'wb')
    end
  end
end
