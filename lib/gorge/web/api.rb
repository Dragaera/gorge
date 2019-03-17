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
          requires :steam_id,           type: Integer,       desc: 'Steam ID'
          requires :statistics_classes, type: Array[String], desc: 'Identifiers of statistics classes'
        end
        route_param :steam_id do
          get :statistics do
            player = Player.first(steam_id: params[:steam_id])
            unless player
              error! 'No such player', 404
            end

            classes = params[:statistics_classes].map do |name|
              cls = PlayerStatisticsClass.first(name: name)
              unless cls
                error! "No such statistics class: #{ name }", 404
              end

              cls
            end

            classes.map do |cls|
              [
                cls.name,
                {
                  _: { sample_size: cls.sample_size },
                }.merge(player.cached_statistics(statistics_class: cls))
              ]
            end.to_h
          end
        end
      end
    end
  end
end
