require 'json'
require 'logger'

module Gorge
  def self.logger(*args, **kwargs)
    StructuredLogger.new(*args, **kwargs)
  end

  class StructuredLogger
    def initialize(level: :debug, program: 'gorge')
      @program = program

      @logger       = Logger.new(STDOUT)
      @logger.level = level

      @logger.formatter = proc do |severity, dt, _, message|
        msg = message.dup
        if msg.is_a? Hash
          msg.merge! @attributes
        elsif msg.is_a? String
          attr_string = @attributes.map { |k, v| "#{ k } = #{ v }" }.join(', ')
          msg = "#{ msg } (#{ attr_string })"
        end

        JSON.dump(
          {
            time:     dt.iso8601,
            severity: severity,
            program:  [@program, @module].compact.join('/'),
            message:  msg,
            pid:      Process.pid
          }
        ) + "\n"
      end

      @attributes = {}
    end

    def module=(val)
      @module = val
    end

    def debug(msg)
      @logger.debug(msg)
    end

    def info(msg)
      @logger.info(msg)
    end

    def warn(msg)
      @logger.warn(msg)
    end

    def error(msg)
      @logger.error(msg)
    end

    def fatal(msg)
      @logger.fatal(msg)
    end

    def unknown(msg)
      @logger.unknown(msg)
    end

    def add_attribute(key, val)
      @attributes[key] = val
    end

    def remove_attribute(key)
      @attributes.delete key
    end
  end
end
