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
      WEB_PATH = ENV['RESQUE_WEB_PATH']
    end

    module DataImport
      STORAGE_PATH         = ENV.fetch('DATA_IMPORT_STORAGE_PATH')
      HTTP_CONNECT_TIMEOUT = ENV.fetch('DATA_IMPORT_HTTP_CONNECT_TIMEOUT', 30).to_i
    end
  end
end
