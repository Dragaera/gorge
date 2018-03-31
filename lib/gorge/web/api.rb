# coding: utf-8

module Gorge
  module Web
    class API < Grape::API
      logger Gorge.logger(program: 'api', module_: 'players')
      use GrapeLogging::Middleware::RequestLogger, { logger: Gorge.logger(program: 'api', module_: 'requests') }

      if Config::API::ENABLE_AUTHENTICATION
        http_basic do |username, password|
          user = APIUser.authenticate(username, password)
          if user
            logger.debug({ msg: 'authentication success', user: username })
            true
          else
            logger.warn({ msg: 'authentication failure', user: username })
            false
          end
        end
      end

      helpers do
        def logger
          API.logger
        end
      end

      format :json

      resource :players do

        desc "Return a player's statistics"
        params do
          requires :steam_id, type: Integer, desc: 'Steam ID'
        end
        route_param :steam_id do
          get :statistics do
            player = Player.first(steam_id: params[:steam_id])

            if player
              player.statistics
            else
              error! 'No such player', 404
            end
          end
        end
      end
    end
  end
end
