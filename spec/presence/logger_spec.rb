require 'spec_helper'

describe Presence::Logger do
  let(:level) { ::Logger::INFO }
  let(:io) { StringIO.new }
  let(:log) {
    log = ::Logger.new(io)
    log.level = level
    log.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
    log
  }
  let(:logger) { Presence::Logger.new(log) }

  context 'with no ::Logger specified' do
    let(:log) { nil }

    it 'logs warnings to stdout by default' do
      result = capture_stdout do |variable|
        logger.log.warn('Run, baby, run!')
      end
      result.should == "Run, baby, run!\n"
    end

    it 'does not log info by default' do
      result = capture_stdout do |variable|
        logger.log.info('Run, baby, run!')
      end
      result.should == ''
    end
  end

  context 'with DEBUG logging' do
    let(:level) { ::Logger::DEBUG }

    it 'logs ip_scanned events' do
      logger.ip_scanned('10.0.1.1', 'sudo arping', 'nada')
      io.string.should == " - Checked 10.0.1.1 with sudo arping\n    nada\n"
    end

    it 'logs localhost_found events' do
      logger.localhost_found('10.0.1.1', 'AA:BB:CC:DD:EE:FF')
      io.string.should == " * Found localhost!\n"
    end

    it 'logs mac_found events' do
      logger.mac_found('10.0.1.1', 'aa:bb:cc:dd:ee:ff')
      io.string.should == " * Found aa:bb:cc:dd:ee:ff at 10.0.1.1\n"
    end

    it 'logs mac_not_found events' do
      logger.mac_not_found('10.0.1.1')
      io.string.should == " * No MAC found at 10.0.1.1\n"
    end

    it 'logs unknown events' do
      logger.respond_to?(:miracle_occurred).should be_true
      logger.miracle_occurred('256.256.256.256', 'GG:GG:GG:GG:GG:GG', 49)
      io.string.should == "miracle_occurred: [\"256.256.256.256\", \"GG:GG:GG:GG:GG:GG\", 49]\n"
    end

  end

  context 'with INFO logging' do
    let(:level) { ::Logger::INFO }

    it 'logs listener_registered events' do
      logger.listener_registered(logger, 'Scanner')
      io.string.should == "Registered listener: <Presence::Logger> for: Scanner\n"
    end

    it 'logs scan_started events' do
      logger.scan_started('10.0.1', (1..255))
      io.string.should == "Scanning range: 10.0.1.1 to 10.0.1.255\n"
    end

    it 'logs scan_finished events' do
      logger.scan_finished('10.0.1', (1..255))
      io.string.should == "Scan finished.\n"
    end

    it 'does not log ip_scanned events' do
      logger.ip_scanned('10.0.1.1', 'sudo arping', 'nada')
      io.string.should == ''
    end

    it 'does not log localhost_found events' do
      logger.localhost_found('10.0.1.1', 'aa:bb:cc:dd:ee:ff')
      io.string.should == ''
    end

    it 'does not log mac_found events' do
      logger.mac_found('10.0.1.1', 'aa:bb:cc:dd:ee:ff')
      io.string.should == ''
    end

    it 'does not log mac_not_found events' do
      logger.mac_not_found('10.0.1.1')
      io.string.should == ''
    end
  end
end
