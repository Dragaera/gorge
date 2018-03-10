# coding: utf-8

module Gorge
  module Web
    class API < Grape::API
      logger.formatter = GrapeLogging::Formatters::Json.new
      use GrapeLogging::Middleware::RequestLogger, { logger: logger }

      format :json

      resource :foo do
        get :bar do
          'Hello world'
        end
      end

    end
  end
end
