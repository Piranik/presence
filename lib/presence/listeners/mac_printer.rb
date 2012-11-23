module Presence

  # Scanner listener that prints all MACs found by the scanner to stdout.
  class MACPrinter
    def mac_found(ip, mac)
      puts "#{ip} : #{mac}"
    end
  end
end
