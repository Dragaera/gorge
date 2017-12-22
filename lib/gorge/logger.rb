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
        JSON.dump(
          {
            time:     dt.iso8601,
            severity: severity,
            program:  [@program, @module].compact.join('/'),
            message:  message,
            pid:      Process.pid
          }
        ) + "\n"
      end
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
  end
end
