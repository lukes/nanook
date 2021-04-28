# frozen_string_literal: true

RSpec.describe Nanook::Rpc do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }

  it 'should allow you to connect to a custom host' do
    custom_uri = 'http://example.com:7076'

    stub_request(:post, custom_uri).with(
      body: '{"action":"block_count"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{}',
      headers: {}
    )

    Nanook::Rpc.new(custom_uri).call(:block_count)
  end

  it 'should raise an error if there is no scheme in the uri' do
    expect do
      Nanook::Rpc.new('localhost:7076')
    end.to raise_error(ArgumentError,
                       'URI must have http or https in it. Was given: localhost:7076')
  end

  it 'should return errors for non-200 status codes' do
    stub_request(:post, uri).with(
      body: '{"action":"block_count"}',
      headers: headers
    ).to_return(
      status: 500,
      body: '{}',
      headers: {}
    )

    expect do
      Nanook::Rpc.new.call(:block_count)
    end.to raise_error(Nanook::ConnectionError,
                       'Encountered net/http error 500: Net::HTTPInternalServerError')
  end

  it 'should parse the response of the RPC to convert certain strings of primitives to primitives' do
    stub_request(:post, uri).with(
      body: '{"action":"some_action","p1":"1","p2":"2"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"true_value":"true","false_value":"false","number":"1","string":"my_string","array_of_things":["string","1","true"],"hash":{"this":"that"}}',
      headers: {}
    )

    response = Nanook::Rpc.new.call(:some_action, p1: 1, p2: 2)
    expect(response).to eql({ true_value: true, false_value: false, number: 1, string: 'my_string',
                              array_of_things: ['string', 1, true], hash: { this: 'that' } })
  end

  it 'connection test' do
    stub_request(:post, uri).with(
      body: '{"action":"telemetry"}',
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
          {
            "block_count": "5777903",
            "cemented_count": "688819",
            "unchecked_count": "443468",
            "account_count": "620750",
            "bandwidth_cap": "1572864",
            "peer_count": "32",
            "protocol_version": "18",
            "uptime": "556896",
            "genesis_block": "F824C697633FAB78B703D75189B7A7E18DA438A2ED5FFE7495F02F681CD56D41",
            "major_version": "21",
            "minor_version": "0",
            "patch_version": "1",
            "pre_release_version": "2",
            "maker": "3",
            "timestamp": "1587055945990",
            "active_difficulty": "ffffffcdbf40aa45"
        }
      BODY
      headers: {}
    )

    expect(Nanook.new.rpc.test).to eq(true)
  end

  it 'connection test when connection is bad' do
    stub_request(:post, uri).with(
      body: '{"action":"telemetry"}',
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
          {
            "error": "Connection bad"
        }
      BODY
      headers: {}
    )

    expect { Nanook.new.rpc.test }.to raise_error
  end
end
