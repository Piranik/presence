module Presence
  # Wrapper class for shell command execution.
  class Commands
    def arping(ip)
      result = run("sudo arping -c 1 #{ip}")
      [cmd, result]
    end

    def local_ip
      result = run('ifconfig | grep broadcast')
      result.scan(/[\d\.]+/).first
    end

    def run(command)
      `#{command}`
    end
  end
end
