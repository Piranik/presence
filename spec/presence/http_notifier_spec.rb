require 'spec_helper'

describe Presence::HTTPNotifier do
  let(:username) { nil }
  let(:password) { nil }
  let(:notifier) {
    Presence::HTTPNotifier.new(
      url: 'http://example.com/presence_events.json',
      username: username,
      password: password
    )
  }

  let(:scanner) { stub(Presence::Scanner) }
  before { notifier.listener_registered(notifier, scanner) }

  let(:http) { stub(Net::HTTP, :use_ssl= => nil, :verify_mode= => nil) }
  let(:response) { stub(code: '200') }
  before {
    http.stub(:request).and_return(response)
    Net::HTTP.stub(:new).with('example.com', 80).and_return(http)
  }

  context 'with a username and password' do
    let(:username) { 'margot' }
    let(:password) { 'poppie' }

    it 'sends the username and password in the request' do
      http.should_receive(:request) do |r|
        r['authorization'].should == 'Basic bWFyZ290OnBvcHBpZQ=='
        response
      end
      notifier.mac_connected('AA:BB:CC:DD:EE:FF', '10.0.1.49')
    end
  end

  it 'dispatches an error notification if the request returns an error code' do
    response.should_receive(:code).at_least(1).times.and_return('400')
    response.should_receive(:body).and_return('Invalid request')
    scanner.should_receive(:dispatch).with(:http_notification_failed, '400', 'Invalid request')

    notifier.mac_connected('AA:BB:CC:DD:EE:FF', '10.0.1.49')
  end

  it 'dispatches an error notification if the request raises a network error' do
    http.should_receive(:request).and_raise(SocketError.new('bad things occurred'))
    scanner.should_receive(:dispatch).with(:http_notification_failed, 'SocketError', 'bad things occurred')

    notifier.mac_connected('AA:BB:CC:DD:EE:FF', '10.0.1.49')
  end

  it 'sends a POST request on mac_connected' do
    http.should_receive(:request) do |r|
      r.method.should == 'POST'
      r.body.should == 'mac=AA%3ABB%3ACC%3ADD%3AEE%3AFF&ip=10.0.1.49&event=mac_connected'
      response
    end
    notifier.mac_connected('AA:BB:CC:DD:EE:FF', '10.0.1.49')
  end

  it 'sends a POST request on mac_disconnected' do
    http.should_receive(:request) do |r|
      r.method.should == 'POST'
      r.body.should == 'mac=AA%3ABB%3ACC%3ADD%3AEE%3AFF&ip=10.0.1.49&event=mac_disconnected'
      response
    end
    notifier.mac_disconnected('AA:BB:CC:DD:EE:FF', '10.0.1.49')
  end
end
