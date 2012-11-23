module Presence
  # Scanner listener that stores a hash of MAC address to IP address for all
  # MACs found by the scanner.
  class MACList
    attr_accessor :macs_found

    def initialize
      @macs_found = {}
    end

    def mac_found(ip, mac)
      @macs_found[mac] = ip
    end
  end
end
