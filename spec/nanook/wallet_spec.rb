require 'webmock/rspec'
require 'nanook'
WebMock.disable_net_connect!

describe Nanook::Wallet do

  let(:uri) { "http://localhost:7076" }
  let(:account_id) { "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000" }
  let(:wallet_id) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nanook gem'
    }
  }

  before do
    @nano = Nanook.new
  end

  it "wallet create" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_create\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"wallet\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\"}",
      headers: {}
    )

    @nano.wallet.create
  end

  it "wallet destroy" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_destroy\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{}",
      headers: {}
    )

    @nano.wallet(wallet_id).destroy
  end

  it "wallet export" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_export\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"json\":\"{\\\"0000000000000000000000000000000000000000000000000000000000000000\\\": \\\"0000000000000000000000000000000000000000000000000000000000000001\\\"}\"}",
      headers: {}
    )

    @nano.wallet(wallet_id).export
  end

  it "wallet contains" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"exists\":\"1\"}",
      headers: {}
    )

    @nano.wallet(wallet_id).contains(account_id)
  end

  it "wallet contains?" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"exists\":\"1\"}",
      headers: {}
    )

    expect(@nano.wallet(wallet_id).contains?(account_id)).to be true
  end

  it "wallet locked" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_locked\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"locked\":\"0\"}",
      headers: {}
    )

    @nano.wallet(wallet_id).locked
  end

  it "wallet locked? when it is not locked" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_locked\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"locked\":\"0\"}",
      headers: {}
    )

    expect(@nano.wallet(wallet_id).locked?).to be false
  end

  it "wallet locked? when it is locked" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_locked\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"locked\":\"1\"}",
      headers: {}
    )

    expect(@nano.wallet(wallet_id).locked?).to be true
  end

end
