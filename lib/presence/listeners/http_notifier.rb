require "net/https"
require "uri"

module Presence

  # Scanner listener that sends an HTTP notification whenever a new client
  # connects or when a connected client disconnects. This listener is intended
  # to be used with Presence::Tracker when scanning in a loop.
  class HTTPNotifier

    def initialize(options = nil)
      options ||= {}
      @options = {
        use_ssl: false,
        verify_mode: OpenSSL::SSL::VERIFY_PEER
      }.merge(options)
    end

    def listener_registered(l, scanner)
      @scanner ||= scanner
    end

    def mac_connected(mac, ip)
      notify(:mac_connected, { mac: mac, ip: ip })
    end

    def mac_disconnected(mac, old_ip)
      notify(:mac_disconnected, { mac: mac, ip: old_ip })
    end

    protected

    def notify_uri
      @notify_uri ||= URI.parse(@options[:url])
    end

    def notify(event, params)
      request = prepare_request(event, params)
      do_request(request)
    end

    def do_request(request)
      response = nil

      begin
        http      = prepare_http
        response  = http.request(request)
        check_response(response)
      rescue  SocketError,
              Timeout::Error,
              Errno::ECONNREFUSED,
              Errno::EHOSTDOWN,
              Errno::EHOSTUNREACH,
              Errno::ETIMEDOUT => e
        @scanner.dispatch(:http_notification_failed, e.class.name, e.message)
      end

      response
    end

    def prepare_request(event, params)
      request = Net::HTTP::Post.new(notify_uri.request_uri, @options[:headers])
      request.set_form_data(params.merge(event: event))
      if @options[:username]
        request.basic_auth(@options[:username], @options[:password])
      end
      request
    end

    def prepare_http
      http = Net::HTTP.new(notify_uri.host, notify_uri.port)
      http.use_ssl      = @options[:use_ssl]
      http.verify_mode  = @options[:verify_mode]
      http
    end

    def check_response(response)
      unless (200..206).map(&:to_s).include?(response.code)
        @scanner.dispatch(:http_notification_failed, response.code, response.body)
      end
    end
  end
end
