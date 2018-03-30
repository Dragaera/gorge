module Gorge
  module Config
    module Database
      ADAPTER  = ENV.fetch('DB_ADAPTER')
      HOST     = ENV['DB_HOST']
      PORT     = ENV['DB_PORT']
      DATABASE = ENV.fetch('DB_DATABASE')
      USER     = ENV['DB_USER']
      PASS     = ENV['DB_PASS']
    end

    module Redis
      HOST = ENV.fetch('REDIS_HOST')
      PORT = ENV['REDIS_PORT']
    end

    module Resque
      WEB_PATH           = ENV['RESQUE_WEB_PATH']
      DURATIONS_RECORDED = ENV.fetch('RESQUE_DURATIONS_RECORDED', 10_000).to_i
    end

    module DataImport
      STORAGE_PATH             = ENV.fetch('DATA_IMPORT_STORAGE_PATH')
      HTTP_CONNECT_TIMEOUT     = ENV.fetch('DATA_IMPORT_HTTP_CONNECT_TIMEOUT', 30).to_i
      ERROR_THRESHOLD          = ENV.fetch('DATA_IMPORT_ERROR_THRESHOLD', 5).to_i
      DATA_FILE_RETENTION_TIME = ENV.fetch('DATA_IMPORT_DATA_FILE_RETENTION_TIME', 7 * 24 * 60 * 60).to_i
    end
  end
end
