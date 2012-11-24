require 'logger'

module Presence
  # Scanner listener that sends descriptions of scan events to a log. By
  # default, it uses a Logger instance that writes to stdout. To enable more
  # verbose output, set:
  #
  #   logger.log.level = ::Logger::INFO
  #
  # or:
  #
  #   logger.log.level = ::Logger::DEBUG
  #
  # To write to a file or some other outlet, pass a Ruby Logger instance to the
  # constructor.
  class Logger
    attr_accessor :log

    def initialize(log = nil)
      if log.nil?
        log = ::Logger.new($stdout)
        log.level = ::Logger::WARN
        log.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end
      self.log = log
    end

    def listener_registered(listener, scanner)
      log.info "Registered listener: <#{listener.class}> for: #{scanner}"
    end

    def scan_started(ip_prefix, range)
      log.info "Scanning range: #{ip_prefix}.#{range.first} to #{ip_prefix}.#{range.last}"
    end

    def scan_finished(ip_prefix, range)
      log.info "Scan finished."
    end

    def ip_scanned(ip, cmd, result)
      log.debug " - Checked #{ip} with #{cmd}"
      result.split("\n").each do |l|
        log.debug "    #{l}"
      end
    end

    def localhost_found(ip, mac)
      log.debug " * Found localhost!"
    end

    def mac_found(ip, mac)
      log.debug " * Found #{mac} at #{ip}"
    end

    def mac_not_found(ip)
      log.debug " * No MAC found at #{ip}"
    end

    protected

    def log_unknown_event(method_sym, *arguments)
      # puts "method_sym = #{method_sym}"
      # puts "arguments = #{arguments.inspect}"
      # puts "log = #{log}"
      # raise 'hell'
      log.warn("#{method_sym}: #{arguments.inspect}")
    end

    # Always log events, even if there is no explicit handler. Generate a
    # method at runtime so we don't have to do method_missing every time.
    def method_missing(method_sym, *arguments, &block)
      arg_names = arguments.each_with_index.map { |arg, i| "arg#{i}" }
      arg_list = arg_names.join(',')
      instance_eval <<-RUBY
        def #{method_sym}(#{arg_list})
          log_unknown_event(:#{method_sym}, #{arg_list})
        end
      RUBY
      # def method_sym(arg1, arg2, ...)
      #   log_unknown_event(:method_sym, arg1, arg2, ...)
      # end
      send(method_sym, *arguments)
    end

    # Respond to anything.
    def respond_to_missing?(method_sym, include_private = false)
      true
    end
  end
end
