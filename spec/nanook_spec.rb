require 'webmock/rspec'
require 'nanook'
WebMock.disable_net_connect!

describe Nanook do

  let(:uri) { "http://localhost:7076" }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
    }
  }

  it "should allow you to connect to a custom host" do
    custom_uri = "http://example.com:7076"

    nanook = Nanook.new(custom_uri)

    stub_request(:post, custom_uri).with(
      body: "{\"action\":\"block_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{}",
      headers: {}
    )

    nanook.block_count
  end

  it "should raise an error if there is no scheme in the uri" do
    expect{Nanook.new("localhost:7076")}.to raise_error(ArgumentError, "URI must have http or https in it. Was given: localhost:7076")
  end

  it "should return errors for non-200 status codes" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count\"}",
      headers: headers
    ).to_return(
      status: 500,
      body: "{}",
      headers: {}
    )

    expect{Nanook.new.block_count}.to raise_error(Nanook::Error, "Encountered net/http error 500: Net::HTTPInternalServerError")
  end

  it "should request block_count correctly" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_count\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"count\":\"1000\",\"unchecked\":\"10\"}",
      headers: {}
    )

    response = Nanook.new.block_count
    expect(response).to eql({count:1000,unchecked:10})
  end

  it "should parse the response of the RPC to convert certain strings of primitives to primitives" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"some_action\",\"p1\":\"1\",\"p2\":\"2\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"true_value\":\"true\",\"false_value\":\"false\",\"number\":\"1\",\"string\":\"my_string\"}",
      headers: {}
    )

    response = Nanook.new.rpc(:some_action, p1: 1, p2: 2)
    expect(response).to eql({true_value:true,false_value:false,number:1,string:"my_string"})
  end

end
