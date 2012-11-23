require 'logger'

module Presence
  # Scanner listener that sends descriptions of scan events to a log. By
  # default, it uses a Logger instance that writes to stdout. To enable more
  # verbose output, set:
  #
  #   logger.level = ::Logger::INFO
  #
  # or:
  #
  #   logger.level = ::Logger::DEBUG
  #
  # To write to a file or some other outlet, pass an instance of Logger to the
  # constructor.
  class Logger
    attr_accessor :logger

    def initialize(log = nil)
      if log.nil?
        log = ::Logger.new(STDOUT)
        log.level = ::Logger::WARN
        log.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end
      self.logger = log
    end

    def listener_registered(listener, scanner)
      logger.info "Registered listener: <#{listener.class}> for: #{scanner}"
    end

    def scan_started(ip_prefix, range)
      logger.info "Checking range: #{ip_prefix}.#{range.first} to #{ip_prefix}.#{range.last}"
    end

    def scan_finished(ip_prefix, range)
      logger.info "Scan finished."
    end

    def ip_scanned(ip, cmd, result)
      logger.debug " - Checked #{ip} with #{cmd}"
      result.split("\n").each do |l|
        logger.debug "    #{l}"
      end
    end

    def localhost_found(ip, mac)
      logger.debug " * Found localhost!"
    end

    def mac_found(ip, mac)
      logger.debug
      logger.debug " * Found #{mac} at #{ip}"
      logger.debug
    end

    def mac_not_found(ip)
      logger.debug
      logger.debug " * No MAC found at #{ip}"
      logger.debug
    end
  end
end
