require 'webmock/rspec'
WebMock.disable_net_connect!

describe Nanook::WalletAccounts do

  let(:uri) { "http://localhost:7076" }
  let(:account_id) { "xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000" }
  let(:wallet_id) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }
  let(:block_id) { "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F" }
  let(:headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby nano-rpc gem'
    }
  }

  before do
    @nano = Nanook.new(uri)
  end

  it "wallet accounts all" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_list\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\":[\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"]}",
      headers: {}
    )

    @nano.wallet(wallet_id).accounts.all
  end

  it "wallet accounts create" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_create\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"account\":\"xrb_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: {}
    )

    @nano.wallet(wallet_id).account.create
  end

  it "wallet accounts destroy" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_remove\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"removed\":\"1\"}",
      headers: {}
    )

    @nano.wallet(wallet_id).account(account_id).destroy
  end

  it "wallet accounts send payment" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"send\",\"wallet\":\"#{wallet_id}\",\"source\":\"#{account_id}\",\"destination\":\"#{account_id}\",\"amount\":\"2000000000000000000000000000000\",\"id\":\"7081e2b8fec9146e\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    @nano.wallet(wallet_id).account(account_id).pay(to: account_id, amount: 2, id:"7081e2b8fec9146e")
  end

  it "wallet accounts receive latest pending payment" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"#{block_id}\"]}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"receive\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\",\"block\":\"#{block_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    @nano.wallet(wallet_id).account(account_id).receive
  end

  it "wallet accounts receive latest pending payment when no payment is pending" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[]}",
      headers: {}
    )

    expect(@nano.wallet(wallet_id).account(account_id).receive).to be false
  end

  it "wallet accounts receive payment with block" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"receive\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\",\"block\":\"#{block_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    @nano.wallet(wallet_id).account(account_id).receive(block_id)
  end

end
