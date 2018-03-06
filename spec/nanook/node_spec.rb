require 'webmock/rspec'
require 'nanook/node'
require 'nanook/rpc'
WebMock.disable_net_connect!

describe Nanook::Node do

  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
    }
  }

  it "should request block_count correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"1000\",\"unchecked\":\"10\"}",
      headers: {}
    )

    Nanook.new.node.block_count
  end

  it "should request block_count_type correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count_type\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"send\":\"1000\",\"receive\":\"900\",\"open\":\"100\",\"change\":\"50\"}",
      headers: {}
    )

    Nanook.new.node.block_count_type
  end

  it "should request bootstrap correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"bootstrap\",\"address\":\"::ffff:138.201.94.249\",\"port\":\"7075\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"send\":\"1000\",\"receive\":\"900\",\"open\":\"100\",\"change\":\"50\"}",
      headers: {}
    )

    Nanook.new.node.bootstrap(address: "::ffff:138.201.94.249", port: "7075")
  end

  it "should request bootstrap_any correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"bootstrap_any\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    Nanook.new.node.bootstrap_any
  end

  it "should request representatives correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"representatives\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"representatives\":{\"xrb_1111111111111111111111111111111111111111111111111117353trpda\":\"3822372327060170000000000000000000000\",\"xrb_1111111111111111111111111111111111111111111111111awsq94gtecn\":\"30999999999999999999999999000000\",\"xrb_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi\":\"0\"}}",
      headers: {}
    )

    Nanook.new.node.representatives
  end

  it "should request peers correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"peers\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"peers\":{\"[::ffff:172.17.0.1]:32841\":\"3\"}}",
      headers: {}
    )

    Nanook.new.node.peers
  end

  it "should request stop correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"stop\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"success\":\"\"}",
      headers: {}
    )

    Nanook.new.node.stop
  end

  it "should request version correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"version\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"rpc_version\":\"1\",\"store_version\":\"2\",\"node_vendor\":\"RaiBlocks 7.5.0\"}",
      headers: {}
    )

    Nanook.new.node.version
  end

  it "should request frontier_count correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"frontier_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"100\"}",
      headers: {}
    )

    Nanook.new.node.frontier_count
  end

end
