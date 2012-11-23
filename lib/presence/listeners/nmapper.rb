module Presence

  # Scanner listener that executes and prints the output from nmap for all MACs
  # found by the scanner.
  class NMapper
    def localhost_found(ip, mac)
      @local_ip = ip
      @local_mac = mac
    end

    def mac_found(ip, mac)
      return if ip == @local_ip

      result = `sudo nmap -O #{ip}`
      puts '*' * 50
      puts "* IP: #{ip}"
      result.split("\n").each do |l|
        puts "    #{l}"
      end
      puts '*' * 50
    end
  end
end
