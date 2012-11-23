require 'spec_helper'

describe Presence::Scanner do
  let(:local_ip)  { '10.0.1.30' }
  let(:local_mac) { '8d:1d:bc:3b:fa:4c' }

  let(:ip)          { '10.0.1.31' }
  let(:mac)         { 'd8:d1:cb:b3:af:c4' }
  let(:arping_cmd)  { "sudo arping -c 1 #{ip}" }

  let(:commands) {
    commands = stub(Presence::Commands)
    Presence::Commands.should_receive(:new).and_return(commands)
    commands
  }
  let(:listener) {
    listener = mock(Object)
    scanner.register_listener(listener)
    listener
  }
  let(:octet_range) { (30..32) }
  let(:scanner) { Presence::Scanner.new(octet_range: octet_range) }

  before {
    commands.stub(:local_ip).and_return(local_ip)
    commands.stub(:arping).and_return([arping_cmd, 'No such jeaun'])
    commands.stub(:arping).with(local_ip).and_return([arping_cmd, local_mac])
    commands.stub(:arping).with(ip).and_return([arping_cmd, mac])
  }

  describe '#scan' do
    it 'dispatches a scan_started event' do
      listener.should_receive(:scan_started).with('10.0.1', octet_range)
      scanner.scan
    end

    it 'dispatches a scan_finished event' do
      listener.should_receive(:scan_finished).with('10.0.1', octet_range)
      scanner.scan
    end

    it 'scans all IPs in the range' do
      listener.should_receive(:ip_scanned).with('10.0.1.30', arping_cmd, local_mac)
      listener.should_receive(:ip_scanned).with('10.0.1.31', arping_cmd, mac)
      listener.should_receive(:ip_scanned).with('10.0.1.32', arping_cmd, 'No such jeaun')
      scanner.scan
    end
  end

  describe '#scan_ip' do
    it 'executes arping to check for a mac address' do
      commands.should_receive(:arping).with(ip).and_return([arping_cmd, mac])
      scanner.scan_ip(ip)
    end

    it 'dispatches an ip_scanned event' do
      listener.should_receive(:ip_scanned).with(ip, arping_cmd, mac)
      scanner.scan_ip(ip)
    end

    it 'dispatches a mac_found event' do
      listener.should_receive(:mac_found).with(ip, mac)
      scanner.scan_ip(ip)
    end

    context 'with a localhost IP' do
      it 'dispatches a localhost_found event' do
        listener.should_receive(:localhost_found).with(local_ip, local_mac)
        scanner.scan_ip(local_ip)
      end
    end

    context 'with a non-existent IP' do
      before {
        commands.stub(:arping).with(ip).and_return([arping_cmd, 'No such jeaun'])
      }

      it 'does not dispatch a mac_found event' do
        listener.should_not_receive(:mac_found)
        scanner.scan_ip(ip)
      end

      it 'dispatches an ip_scanned event' do
        listener.should_receive(:ip_scanned).with(ip, arping_cmd, 'No such jeaun')
        scanner.scan_ip(ip)
      end

      it 'dispatches a mac_not_found event' do
        listener.should_receive(:mac_not_found).with(ip)
        scanner.scan_ip(ip)
      end
    end
  end
end
