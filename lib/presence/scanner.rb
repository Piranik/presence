require 'presence/errors'

module Presence

  # Scans a network for connected clients, captures the MAC address, and
  # dispatches related events to any registered listeners.
  class Scanner
    PAIR = '[0-9a-f]{2}'
    SEP = '\:'
    MAC_REGEXP = Regexp.new("(#{6.times.map {PAIR}.join(SEP)})")

    attr_accessor :listeners, :options

    def initialize(options = nil)
      options ||= {}
      self.options = {
        ip_prefix:    nil,
        octet_range: (1..255)
      }.merge(options)
      self.listeners = []
      @commands = Presence::Commands.new
    end

    def register_listener(l)
      raise Presence::InvalidListener.new("Listener cannot be nil") if l.nil?
      listeners << l
      dispatch(:listener_registered, l, self)
    end

    def localhost_ip
      unless @localhost_ip
        @localhost_ip = @commands.local_ip
      end
      @localhost_ip
    end

    def ip_prefix
      unless options[:ip_prefix]
        options[:ip_prefix] = localhost_ip.split('.')[0,3].join('.')
      end
      options[:ip_prefix]
    end

    def octet_range
      options[:octet_range]
    end

    def scan
      dispatch(:scan_started, ip_prefix, octet_range)
      octet_range.each do |i|
        scan_ip("#{ip_prefix}.#{i}")
      end
      dispatch(:scan_finished, ip_prefix, octet_range)
    end

    def scan_ip(ip)
      cmd, result = @commands.arping(ip)
      dispatch(:ip_scanned, ip, cmd, result)
      process_scan_result(ip, cmd, result)
    end

    def process_scan_result(ip, cmd, result)
      if result =~ MAC_REGEXP
        mac = $1
        dispatch(:localhost_found, ip, mac) if ip == localhost_ip
        dispatch(:mac_found, ip, mac)
      else
        dispatch(:mac_not_found, ip)
      end
    end

    def dispatch(event, *args)
      listeners.each do |l|
        l.send(event, *args) if l.respond_to?(event)
      end
    end

    def to_s
      "<#{self.class} ip_prefix: '#{self.ip_prefix}' octet_range: (#{self.octet_range})>"
    end

    class << self
      def check_env
        commands = Commands.new
        if commands.run('which ifconfig').size == 0
          raise Presence::InvalidEnvironment.new("Unsupported platform: ifconfig not found.")
        end
        if commands.run('which arping').size == 0
          raise Presence::InvalidEnvironment.new("Unsupported platform: arping not found.")
          raise Presence::InvalidEnvironment.new("Install arping first: brew install arping")
        end
      end

      def scan_loop(&block)
        scanner = self.new
        yield(scanner) if block_given?

        while(true)
          begin
            scanner.scan
          rescue Interrupt
            break
          end
        end
      end
    end
  end
end
