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

end
