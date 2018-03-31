# coding: utf-8

module Gorge
  class APIUser < Sequel::Model
    UUID_GENERATION_RETRIES = 10

    # @return [APIUser] New API user with guaranteed-unique UUID-based user id.
    # @raise [RuntimeError] If no unique user id could be generated.
    def self.generate(description = nil)
      logger.info("Generating API User.")

      uuid = SecureRandom.uuid
      i = 1
      while (first(user: uuid)) do
        logger.info("Retrying for new UUID because UUID #{ uuid } is taken.")
        uuid = SecureRandom.uuid
        i += 1

        raise RuntimeError, 'Too many attempts at creating unique UUID' if i > UUID_GENERATION_RETRIES
      end

      token = SecureRandom.hex(64 / 2)

      logger.info({ msg: 'Generated API user', user: uuid, token: token })
      APIUser.create(user: uuid, token: token, description: description)
    end

    def self.authenticate(user, token)
      return nil unless UUID.validate user

      user = APIUser.where(enabled: true).first(user: user, token: token)
      user.update(last_used_at: Time.now) if user

      user
    end

    private
    def self.logger
      @logger ||= Gorge.logger(program: 'models', module_: 'APIUser')
    end
  end
end
