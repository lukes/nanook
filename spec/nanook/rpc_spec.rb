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
    end.to raise_error(Nanook::Error,
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
end
