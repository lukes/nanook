require 'webmock/rspec'
require 'nanook/work_peer'
WebMock.disable_net_connect!

describe Nanook::Key do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
    }
  }

  it "should add a work peer correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_peer_add\",\"address\":\"::ffff:172.17.0.1:7076\",\"port\":\"7076\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    Nanook.new.work_peers.add(address: "::ffff:172.17.0.1:7076", port: 7076)
  end

  it "should clear work peers correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_peers_clear\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    Nanook.new.work_peers.clear
  end

  it "should list work peers correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_peers\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"work_peers\":[\"::ffff:172.17.0.1:7076\"]}",
      headers: {}
    )

    Nanook.new.work_peers.list
  end


end
