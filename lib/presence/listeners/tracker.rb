require 'presence/listeners/mac_list'

module Presence

  # Scanner listener that tracks all MACs found by the scanner. This listener is
  # intended to be used when scanning in a loop. The tracker will maintain a
  # list of MAC addresses on the network and detect when a new client connects
  # or when a connected client disconnects.
  class Tracker
    def initialize
      @mac_history = {}
      @current_list = Presence::MACList.new
    end

    def listener_registered(l, scanner)
      scanner.register_listener(@current_list) if l == self
    end

    def mac_found(ip, mac)
      if @mac_history[mac].nil?
        mac_connected(mac, ip)
      elsif @mac_history[mac] != ip
        mac_changed(mac, @mac_history[mac], ip)
      end
      @mac_history[mac] = ip
    end

    def scan_finished(ip_prefix, range)
      macs_left = @mac_history.keys - @current_list.macs_found.keys
      macs_left.each do |mac|
        old_ip = @mac_history[mac]
        mac_disconnected(mac, old_ip)
        @mac_history.delete(mac)
      end
      @current_list.macs_found.clear
    end

    def mac_connected(mac, ip)
      puts " ** #{mac} connected as #{ip}"
      # Do something interesting.
    end

    def mac_changed(mac, old_ip, new_ip)
      puts " ** #{mac} changed ip from: #{old_ip} to #{new_ip}"
      # Do something interesting.
    end

    def mac_disconnected(mac, old_ip)
      puts " ** #{mac} disconnected from #{old_ip}"
      # Do something interesting.
    end
  end
end
