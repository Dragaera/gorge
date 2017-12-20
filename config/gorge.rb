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
  end
end
